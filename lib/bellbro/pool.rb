module Bellbro
  module Pool

    def with_connection(key: nil)
      key ||= db_name
      db = directory(key)
      retryable(sleep: 0.5) do
        Bellbro::Settings.connection_pool.with do |c|
          c.select(db)
          yield c
        end
      end
    end

    def db_name
      self.class.db_name
    end

    def directory(name)
      Bellbro::Settings.db_directory[name]
    end

    def self.included(klass)
      klass.extend(self)

      class << klass
        def set_db(db_name)
          @db_name = db_name
        end
        
        def db_name
          @db_name
        end
      end
    end
  end
end