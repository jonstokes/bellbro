require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'bellbro'
require 'rspec'

#Dir[File.join(File.dirname(__FILE__),'../spec/support/**/*.rb')].each { |f| require f }
#Dir[File.join(File.dirname(__FILE__),'../spec/factories/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.order = 'random'
  #config.include FactoryGirl::Syntax::Methods
end
