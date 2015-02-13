module Bellbro
  module Pool

    def with_connection(key: nil)
      self.class.with_connection(key)
    end

    def db_name
      self.class.db_name
    end

    def self.included(klass)
      klass.extend(self)
      klass.extend(ClassMethods)

    end

    def ClassMethods
      def with_connection(key: nil)
        key ||= db_name
        db = directory(key)
        retryable(sleep: 0.5) do
          Sidekiq.redis.with do |c|
            c.select(db)
            yield c
          end
        end
      end

      def directory(name)
        Bellbro::Settings.db_directory[name]
      end

      def set_db(db_name)
        @db_name = db_name
      end

      def db_name
        @db_name
      end

    end
  end
end