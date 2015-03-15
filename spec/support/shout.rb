logger = Yell.new do |l|
  l.level = [:debug, :info, :warn, :error]
end

Shout::Settings.configure do |config|
  config.logger = logger
end