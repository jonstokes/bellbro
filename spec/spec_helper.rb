require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'bellbro'
require 'rspec'
require 'yell'

Dir[File.join(File.dirname(__FILE__),'../spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.order = 'random'
end