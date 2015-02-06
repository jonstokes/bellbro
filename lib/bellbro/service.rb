require 'digest'

module Bellbro
  class Service < Bellbro::Bell
    include Bellbro::SidekiqUtils
    include Bellbro::Trackable

    SLEEP_INTERVAL = Rails.env.test? ? 1 : 3600
    LOG_RECORD_SCHEMA = { jobs_started: Integer }

    attr_reader :thread, :thread_error, :jid

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
          Airbrake.ring(@thread_error)
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
        sleep self.class::SLEEP_INTERVAL
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
  end

end
