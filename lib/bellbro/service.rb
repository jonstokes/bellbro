require 'digest'

module Bellbro
  class Service
    include Bellbro::SidekiqUtils
    include Bellbro::Trackable
    include Bellbro::Ringable

    attr_reader :thread, :thread_error, :jid

    def self.poll_interval(arg)
      if defined?(Rails) && Rails.env.test?
        @sleep_interval = 0.5
      else
        @sleep_interval = arg
      end
    end

    def self.worker_class(arg)
      @worker_class = arg
    end

    def self.get_worker_class
      @worker_class
    end

    poll_interval defined?(Rails) && Rails.env.test? ? 1 : 3600
    track_with_schema jobs_started: Integer

    def initialize
      @done = false
      @jid = Digest::MD5.hexdigest(Time.now.utc.to_s + Thread.current.object_id.to_s)
    end

    def start
      @thread = Thread.new do
        begin
          run
        rescue Exception => @thread_error
          log "#{@thread_error.inspect}", type: :error
          Airbrake.notify(@thread_error)
          raise @thread_error
        end
      end
    end

    def stop
      @done = true
      log "Stopping #{self.class} service..."
      @thread.join
      log "#{self.class.to_s.capitalize} service stopped."
    end

    def run
      log "Starting #{self.class} service."
      self.class.mutex.synchronize { track }
      begin
        self.class.mutex.synchronize { start_jobs }
        self.class.mutex.synchronize { status_update }
        sleep
      end until @done
      self.class.mutex.synchronize { stop_tracking }
    end

    def start_jobs
      each_job do |job|
        jid = worker_class.perform_async(job)
        log "Starting job #{jid} #{worker_class.name} with #{job.inspect}."
        record_incr(:jobs_started)
      end
    end

    def sleep
      super(self.class.sleep_interval)
    end

    def each_job
      # Override
      []
    end

    def running?
      !@done
    end

    def worker_class
      @worker_class ||= self.class.get_worker_class
    end

    def self.mutex
      $mutex ||= Mutex.new
    end

    def self.sleep_interval
      @sleep_interval
    end

  end

end
