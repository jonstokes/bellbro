module Bellbro
  module Settings

    class SettingsData < Struct.new(
        :logger, :env
    )
    end

    def self.configure
      $bellbro_configuration ||= Bellbro::Settings::SettingsData.new
      yield $bellbro_configuration
    end

    def self.env
      return unless configured?
      $bellbro_configuration.env
    end

    def self.test?
      return unless configured?
      $bellbro_configuration.env == 'test'
    end

    def self.logger
      return unless configured?
      $bellbro_configuration.logger
    end

    def self.configured?
      !!$bellbro_configuration
    end
  end
end
