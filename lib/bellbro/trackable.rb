module Bellbro
  module Trackable
    include Bellbro::Retryable

    attr_reader :record

    def self.included(klass)
      class << klass
        def track_with_schema(hash)
          self.class_eval do
            @log_record_schema = hash
          end
        end

        def log_record_schema
          @log_record_schema
        end
      end
    end

    def track(opts={})
      return if @log_record_schema # Ignore repeated calls to #track, as in RefreshLinksWorker
      opts.symbolize_keys!
      @log_record_schema = self.class.log_record_schema
      @write_interval = opts[:write_interval] || 500
      @count = 0
      @tracking = true
      initialize_log_record
      status_update(true)
    end

    def status_update(force = false)
      return unless force || ((@count += 1) % @write_interval) == 0
      retryable { write_log(@record.to_json) }
    end

    def write_log(line)
      Bellbro.logger.info line
    end

    def record_set(attr, value)
      attr = attr.to_sym
      validate(attr => value)
      @record[:data][attr] = value
    end

    def record_incr(attr)
      attr = attr.to_sym
      validate(attr => 1)
      @record[:data][attr] += 1
    end

    def stop_tracking
      @record[:complete] = true
      @record[:stopped] = Time.now.utc.iso8601
      @tracking = false
      status_update(true)
    end

    def tracking?
      !!@tracking
    end

    private

    def initialize_log_record
      @record = {
          host:   Socket.gethostname,
          agent: {
              name:   "#{self.class.name}",
              thread: "#{Thread.current.object_id}",
              jid:    jid,
          },
          domain: @site.try(:domain) || @domain,
          complete: false,
          started: Time.now.utc.iso8601,
          data: {}
      }

      @log_record_schema.each do |k, v|
        if v == Integer
          @record[:data][k] = 0
        else
          @record[:data][k] = v.new
        end
      end
    end

    def log_record_attributes
      @log_record_schema.keys + [:jid, :agent, :archived]
    end

    def validate(attrs)
      attrs.each do |attr, value|
        raise "Invalid attribute #{attr}" unless log_record_attributes.include?(attr)
        raise "Invalid type for #{attr}" unless [value.class, value.class.superclass].include?(@log_record_schema[attr])
      end
    end

  end
end