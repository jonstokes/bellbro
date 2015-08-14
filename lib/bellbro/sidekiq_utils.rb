require 'retryable'

module Bellbro
  module SidekiqUtils

    class Queue
      def self.names
        Sidekiq::Stats::Queues.new.lengths.keys
      end

      def self.all
        names.map do |name|
          Sidekiq::Queue.new(name)
        end
      end

      def self.each
        names.each do |name|
          yield Sidekiq::Queue.new(name)
        end
      end

      def self.clear_all
        each do |q|
          q.clear
        end
      end
    end

    class Job
      attr_accessor :source

      def initialize(source)
        @source = source
      end

      def method_missing(method_name, *args, &block)
        source.args.first.try(:[], method_name.to_s)
      end

      def jid
        source.jid
      end

      def self.all_for_class(klass_name)
        Retryable.retryable(on: Redis::TimeoutError) do
          Queue.all.map do |q|
            q.map do |job|
              next unless job.klass == klass_name
              new(job)
            end
          end.flatten.compact
        end
      end
    end

    class Worker
      attr_accessor :source

      def initialize(source)
        @source = source
      end

      def method_missing(method_name, *args, &block)
        args.first.try(:[],method_name.to_s)
      end

      def payload
        source["payload"] || {}
      end

      def args
        payload["args"] || []
      end

      def jid
        payload["jid"]
      end

      def time
        source["run_at"]
      end

      def klass
        payload["class"]
      end

      def queue
        source["queue"]
      end

      def self.all
        Sidekiq::Workers.new.map do |process_id, thread_id, worker|
          worker
        end
      end

      def self.all_for_class(klass_name)
        Retryable.retryable(on: Redis::TimeoutError) do
          all.select do |worker|
            worker.klass == klass_name
          end
        end
      end
    end

    def workers
      Worker.all_for_class("#{self.name}")
    end

    def jobs
      Job.all_for_class("#{self.name}")
    end

    def jobs_in_flight_with(arg)
      jobs_with(arg) + workers_with(arg)
    end

    def jobs_with(arg)
      key   = arg.keys.first
      value = arg.values.first
      jobs.select do |job|
        value == job.send(key)
      end
    end

    def workers_with(arg)
      key   = arg.keys.first
      value = arg.values.first
      workers.select do |worker|
        value == worker.send(key)
      end
    end

    def workers_for_queue(q)
      workers.select do |worker|
        worker.queue == q
      end
    end

    def number_of_active_workers(q_name)
      workers_for_queue(q_name).count
    end
  end
end
