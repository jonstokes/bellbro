require 'digest'

module Bellbro
  class Service < Bellbro::Bell
    include Bellbro::SidekiqUtils
    include Bellbro::Trackable

    attr_reader :thread, :thread_error, :jid

    def self.poll_interval(arg)
      if defined?(Rails) && Rails.env.test?
        @sleep_interval = 0.5
      else
        @sleep_interval = arg
      end
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
          ring "#{@thread_error.inspect}", type: :error
          Airbrake.notify(@thread_error)
          raise @thread_error
        end
      end
    end

    def stop
      @done = true
      ring "Stopping #{self.class} service..."
      @thread.join
      ring "#{self.class.to_s.capitalize} service stopped."
    end

    def run
      ring "Starting #{self.class} service."
      Service.mutex.synchronize { track }
      begin
        start_jobs
        Service.mutex.synchronize { status_update }
        sleep
      end until @done
      Service.mutex.synchronize { stop_tracking }
    end

    def start_jobs
      each_job do |job|
        klass = job[:klass].constantize
        jid = klass.perform_async(job[:arguments])
        ring "Starting job #{jid} #{job[:klass]} with #{job[:arguments]}."
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

    def self.mutex
      $mutex ||= Mutex.new
    end

    def self.sleep_interval
      @sleep_interval
    end

  end

end
