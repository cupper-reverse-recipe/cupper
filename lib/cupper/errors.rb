require 'i18n'

module Cupper

  module Errors

    class CupperError < StandardError
      attr_accessor :extra_data

      def self.error_key(key=nil, namespace=nil)
        define_method(:error_key) { key }
        error_namespace(namespace) if namespace
      end

      def self.error_message(message)
        define_method(:error_message) { message }
      end

      def self.error_namespace(namespace)
        define_method(:error_namespace) { namespace }
      end

      def translate_error(opts)
        return nil if !opts[:_key]
        I18n.t("#{opts[:_namespace]}.#{opts[:_key]}", opts)
      end

      def initialize(*args)
        key     = args.shift if args.first.is_a?(Symbol)
        message = args.shift if args.first.is_a?(Hash)
        message ||= {}
        @extra_data    = message.dup
        message[:_key] ||= error_key
        message[:_namespace] ||= error_namespace
        message[:_key] = key if key
        I18n.load_path << File.expand_path("../../../templates/locales/en.yml", __FILE__)

        if message[:_key]
          message = translate_error(message)
        else
          message = error_message
        end

        super(message)
      end

      # The error message for this error. This is used if no error_key
      # is specified for a translatable error message.
      def error_message; "No error message"; end

      # The default error namespace which is used for the error key.
      # This can be overridden here or by calling the "error_namespace"
      # class method.
      def error_namespace; "cupper.errors"; end

      # The key for the error message. This should be set using the
      # {error_key} method but can be overridden here if needed.
      def error_key; nil; end

      # This is the exit code that should be used when exiting from
      # this exception.
      #
      # @return [Integer]
      def status_code; 1; end

      protected

    end

    class EnvironmentNonExistentCWD < CupperError
      error_key(:environment_non_existent_cwd)
    end

    class NoEnvironmentError < CupperError
      error_key(:no_env)
    end

    class LocalDataDirectoryNotAccessible < CupperError
      error_key(:local_data_dir_not_accessible)
    end

  end

end
