module Bellbro
  module Settings

    class SettingsData < Struct.new(
        :logger, :env, :redis_databases, :redis_pool_size, :redis_url
    )
    end

    def self.configuration
      @configuration ||= Bellbro::Settings::SettingsData.new
    end

    def self.configure
      yield configuration
    end

    def self.env
      return unless configured?
      configuration.env
    end

    def self.test?
      return unless configured?
      configuration.env == 'test'
    end

    def self.redis_databases
      return unless configured?
      configuration.redis_databases
    end

    def self.redis_pool_size
      return unless configured?
      configuration.redis_pool_size
    end

    def self.redis_url
      return unless configured?
      configuration.redis_url
    end

    def self.logger
      return unless configured?
      configuration.logger
    end

    def self.configured?
      !!configuration
    end
  end
end
