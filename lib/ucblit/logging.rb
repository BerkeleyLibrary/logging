require 'ucblit/logging/events'
require 'ucblit/logging/formatters'
require 'ucblit/logging/loggers'

module UCBLIT
  module Logging
    class << self

      # Configures custom logging for a Rails application.
      def configure!
        config = Rails.application.config
        configure_lograge!(config.lograge)

        logger = Loggers.new_default_logger(config)
        logger.info("Custom logger initialized for environment #{Rails.env.inspect}")

        config.logger = logger
        Webpacker::Instance.logger = logger if webpacker?
      end

      private

      def configure_lograge!(lograge)
        return unless lograge

        lograge.enabled = true
        lograge.custom_options = Events.extract_data_for_lograge
        lograge.formatter = Formatters.lograge_formatter
      end

      def webpacker?
        return @webpacker if instance_variable_defined?(:@webpacker)

        require 'webpacker/instance'
        @webpacker = true
      rescue LoadError
        @webpacker = false
      end

    end
  end
end
