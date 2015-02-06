require "bellbro/version"

module Bellbro
  def self.logger
    Bellbro::Settings.logger
  end
end
