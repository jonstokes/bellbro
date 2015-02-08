module Bellbro
  class Worker < Bellbro::Bell
    include Sidekiq::Worker
    include Bellbro::Trackable
    include Bellbro::Hooks
    extend Bellbro::SidekiqUtils

    attr_reader :context

    def perform(args)
      return unless args.present?
      set_context(args)
      run_before_hooks
      return unless should_run?
      call
      run_after_hooks
    end

    def call
      # override
    end

    def should_run?
      # override
      self.class.should_run?
    end

    def self.should_run?
      # override
      true
    end

    private

    def set_context(args)
      if args.is_a?(Hash)
        @context = args.symbolize_keys
      else
        @context = args
      end
    end
  end
end