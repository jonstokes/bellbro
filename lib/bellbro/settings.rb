module Bellbro
  module Settings

    class SettingsData < Struct.new(
        :logger, :env, :connection_pool, :db_directory
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

    def self.connection_pool
      return unless configured?
      configuration.connection_pool
    end

    def self.db_directory
      return unless configured?
      configuration.db_directory
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
