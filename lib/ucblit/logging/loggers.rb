require 'ucblit/logging/env'
require 'ucblit/logging/formatters'
require 'ucblit/logging/logger'

module UCBLIT
  module Logging
    module Loggers
      class << self
        FALLBACK_LOG_DIR = 'log'.freeze

        def new_default_logger(config)
          return new_json_logger($stdout) if Logging.env.production?
          return rails_file_logger(config) if Logging.env.test?
          return new_broadcast_logger(config) if Logging.env.development?

          raise ArgumentError, "Can't create logger for Rails environment: #{Logging.env.inspect}"
        end

        def new_json_logger(logdev)
          new_logger_with(logdev: logdev, formatter: Formatters.new_json_formatter)
        end

        def new_readable_logger(logdev)
          new_logger_with(logdev: logdev, formatter: Formatters.new_readable_formatter)
        end

        private

        def new_broadcast_logger(config)
          new_json_logger($stdout).tap do |json_logger|
            file_logger = rails_file_logger(config)
            json_logger.extend Ougai::Logger.broadcast(file_logger)
          end
        end

        def rails_file_logger(config)
          log_file = default_log_file_for(config)
          new_readable_logger(log_file)
        end

        def new_logger_with(logdev:, formatter:)
          Logger.new(logdev).tap { |l| l.formatter = formatter }
        end

        def default_log_file_for(config)
          return config.default_log_file if config.respond_to?(:default_log_file)

          File.join(ensure_log_directory, "#{Logging.env}.log")
        end

        def ensure_log_directory
          File.join(workdir, FALLBACK_LOG_DIR).tap do |log_dir|
            FileUtils.mkdir(log_dir) unless File.exist?(log_dir)
            raise ArgumentError, "Not a directory: #{log_dir}" unless File.directory?(log_dir)
          end
        end

        def workdir
          return Rails.application.root if defined?(Rails)

          Pathname.getwd
        end

      end
    end
  end
end
