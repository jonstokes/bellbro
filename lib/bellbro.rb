require "bellbro/version"
require 'connection_pool'
require 'active_support/all'
require 'redis'
require 'yaml'
require 'digest'
require 'sidekiq'
require 'airbrake'

%w(
    bellbro/settings.rb
    bellbro/retryable.rb
    bellbro/ringable.rb
    bellbro/trackable.rb
    bellbro/pool.rb
    bellbro/sidekiq_utils.rb
    bellbro/bell.rb
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