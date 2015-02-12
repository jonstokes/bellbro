module Bellbro
  def self.initialize!
    return unless defined?(Rails)
    filename = "#{Rails.root}/config/redis.yml"
    return unless File.exists?(filename)

    config = YAML.load_file(filename)[Rails.env]
    url = Figaro.env.send(config['url'].downcase)
    size = config['pool']

    puts "## Initializing redis pool with size #{size} and url #{url}"
    pool = ConnectionPool.new(size: size) do
      Redis.new(url: url)
    end

    directory = ThreadSafe::Cache.new
    config['databases'].each do |name, db|
      puts "## Db name #{name} mapped to #{db}"
      directory[name.to_sym] = db
    end

    Bellbro::Settings.configure do |config|
      config.connection_pool = pool
      config.db_directory = directory
    end
  end
end

Bellbro.initialize!

