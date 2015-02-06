logger = Yell.new do |l|
  l.level = [:debug, :info, :warn, :error]
end

Bellbro::Settings.configure do |config|
  config.logger = logger
end