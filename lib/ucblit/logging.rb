if defined?(Rails)
  require 'ucblit/logging/railtie'
else
  require 'ucblit/logging/configurator'
end

module UCBLIT
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
        @logger ||= UCBLIT::Logging::Loggers.default_logger
      end

      def logger=(v)
        @logger = (ensure_logger(v) unless v.nil?)
      end

      private

      LOG_METHODS = %i[debug info warn error].freeze

      def ensure_logger(v)
        return v if (missing = LOG_METHODS.reject { |m| v.respond_to?(m) }).empty?

        raise ArgumentError, "Not a logger: #{v.inspect} does not respond to #{missing.join(', ')}"
      end
    end
  end
end
