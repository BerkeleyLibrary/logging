require 'ucblit/logging/env'
require 'ucblit/logging/events'
require 'ucblit/logging/formatters'
require 'ucblit/logging/loggers'

module UCBLIT
  module Logging
    class Configurator
      class << self

        def configure(config)
          configure_lograge(config)

          logger = Loggers.new_default_logger(config)
          logger.info("Custom logger initialized for environment #{Logging.env.inspect}")
          configure_webpacker(logger)
          config.logger = logger
        end

        private

        def configure_lograge(config)
          return unless config.respond_to?(:lograge)

          config.lograge.tap do |lograge|
            lograge.enabled = true
            lograge.custom_options = Events.extract_data_for_lograge
            lograge.formatter = Formatters.lograge_formatter
          end
        end

        def configure_webpacker(logger)
          return unless defined?(::Webpacker)

          logger.info('Using custom logger for Webpacker')
          ::Webpacker::Instance.logger = logger
        end
      end
    end
  end
end
