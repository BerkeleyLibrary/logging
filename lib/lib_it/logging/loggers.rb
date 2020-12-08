require 'lib_it/logging/formatters'
require 'lib_it/logging/tagged_logging_extensions'

module LibIT
  module Logging
    module Loggers
      class << self
        def new_default_logger(config)
          return new_json_logger($stdout) if Rails.env.production?
          return rails_file_logger(config) if Rails.env.test?
          return new_broadcast_logger(config) if Rails.env.development?
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

        def file_logger_for_env(env)
          new_readable_logger("log/#{env}.log")
        end

        def rails_file_logger(config)
          log_file = config.default_log_file
          new_readable_logger(log_file)
        end

        def new_logger_with(logdev:, formatter:)
          AvLogger.new(logdev).tap { |l| l.formatter = formatter }
        end
      end

      class AvLogger < Ougai::Logger
        include ActiveSupport::LoggerThreadSafeLevel
        include ActiveSupport::LoggerSilence
      end
    end
  end
end
