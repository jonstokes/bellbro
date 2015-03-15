require "bellbro/version"
require 'connection_pool'
require 'active_support/all'
require 'redis'
require 'yaml'
require 'digest'
require 'sidekiq'
require 'airbrake'
require 'retryable'

%w(
    bellbro/hooks.rb
    bellbro/trackable.rb
    bellbro/sidekiq_utils.rb
    bellbro/service.rb
    bellbro/worker.rb
).each do |path|
  require File.join(File.dirname(__FILE__),path)
end

module Bellbro
  def self.logger
    Bellbro::Settings.logger
  end
end