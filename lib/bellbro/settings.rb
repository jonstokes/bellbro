module Bellbro
  module Settings

    class SettingsData < Struct.new(
        :logger, :env, :connection_pools
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

    def self.connection_pools
      return unless configured?
      configuration.connection_pools
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
