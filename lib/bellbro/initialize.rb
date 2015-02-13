module Bellbro
  def self.initialize!
    return unless defined?(Rails)
    filename = "#{Rails.root}/config/redis.yml"
    return unless File.exists?(filename)
    config = YAML.load_file(filename)[Rails.env]
    configure_bellbro(config)
  end

  def self.configure_bellbro(config)
    redis_url = config['redis_url']
    databases = ThreadSafe::Cache.new
    config['databases'].each do |name, db|
      puts "## Db name #{name} mapped to #{db}"
      databases[name.to_sym] = db
    end

    Bellbro::Settings.configure do |con|
      con.redis_databases = databases
      con.redis_url = redis_url
      con.redis_pool_size = config['pool']
    end
  end
end
