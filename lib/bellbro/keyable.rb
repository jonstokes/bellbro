module Bellbro
  module Keyable
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    def respond_to?(method)
      return true if @respond_to && @respond_to.include?(method.to_sym)
      super
    end

    module ClassMethods
      def delegate_all_keys(*methods)
        delegate_getter_keys(*methods)
        delegate_setter_keys(*methods)
        delegate_status_keys(*methods)
      end

      def delegate_getter_keys(*methods)
        options = extract_methods(methods)
        options[:methods].each do |key|
          @respond_to << key
          define_method key do
            send(options[:to])[key]
          end
        end
      end

      def delegate_setter_keys(*methods)
        options = extract_methods(methods)
        options[:methods].each do |key|
          @respond_to << "#{key}="
          define_method "#{key}=" do |value|
            send(options[:to])[key] = value
          end
        end
      end

      def delegate_status_keys(*methods)
        options = extract_methods(methods)
        options[:methods].each do |key|
          @respond_to << "#{key}?"
          define_method "#{key}?" do
            !!send(options[:to])[key]
          end
        end
      end

      private

      def extract_methods(methods)
        options = methods.pop
        unless options.is_a?(Hash) && to = options[:to].try(:to_sym)
          raise ArgumentError, 'Delegation needs a target. Supply an options hash with a :to key as the last argument (e.g. delegate :hello, to: :greeter).'
        end

        # Set up the data hash, if needed
        if respond_to?(to) && !send(to).respond_to?(:[]) && !send(to).respond_to?(:[]=)
          raise ArgumentError, 'Target must be a hash-like object.'
        end

        @respond_to ||= []
        { methods: methods.map(&:to_sym), to: to }
      end

    end
  end
end