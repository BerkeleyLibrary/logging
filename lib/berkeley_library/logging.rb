if defined?(Rails)
  require 'berkeley_library/logging/railtie'
else
  require 'berkeley_library/logging/configurator'
end

module BerkeleyLibrary
  # Include this module to get access to a shared global logger.
  module Logging
    def logger
      Logging.logger
    end

    def logger=(v)
      Logging.logger = v
    end

    class << self
      def logger
        @logger ||= BerkeleyLibrary::Logging::Loggers.default_logger
      end

      def logger=(v)
        @logger = (ensure_logger(v) unless v.nil?)
      end

      LOG_METHODS = %i[debug info warn error].freeze

      private

      def ensure_logger(v)
        return v if (missing = LOG_METHODS.reject { |m| v.respond_to?(m) }).empty?

        raise ArgumentError, "Not a logger: #{v.inspect} does not respond to #{missing.join(', ')}"
      end
    end
  end
end
