require 'rails_helper'
require 'rails'

module BerkeleyLibrary
  module Logging
    describe Loggers do
      attr_reader :orig_rails_env

      before(:each) do
        @orig_rails_env = Rails.env
      end

      after(:each) do
        Rails.env = orig_rails_env
      end

      describe :new_json_logger do
        it 'supports tagged logging' do
          out = StringIO.new
          logger = Loggers.new_json_logger(out)
          logger = ActiveSupport::TaggedLogging.new(logger)

          expected_tag = 'hello'
          expected_msg = 'this is a test'

          logger.tagged(expected_tag) { logger.info(expected_msg) }

          logged_json = JSON.parse(out.string)
          expect(logged_json['msg']).to eq(expected_msg)
          expect(logged_json['tags']).to eq([expected_tag])
        end
      end

      describe :default_logger do
        before(:each) { @rails_logger = Rails.logger }
        after(:each) { Rails.logger = @rails_logger }

        it 'returns the Rails logger' do
          expected_logger = double(::Logger)
          Rails.logger = expected_logger

          expect(Loggers.default_logger).to be(expected_logger)
        end

        it 'returns a readable $stdout logger if Rails logger is nil' do
          Rails.logger = nil

          actual_logger = Loggers.default_logger
          expect(actual_logger).to be_a(Logger)
          expect(actual_logger.formatter).to be_a(Ougai::Formatters::Readable)

          logdev = actual_logger.instance_variable_get(:@logdev)
          expect(logdev).to be_a(::Logger::LogDevice)
          expect(logdev.dev).to be($stdout)
        end

        it "doesn't cache the default logger if the Rails logger is initialized later" do
          Rails.logger = nil

          initial_default_logger = Loggers.default_logger

          expected_logger = double(::Logger)
          Rails.logger = expected_logger

          actual_logger = Loggers.default_logger
          expect(actual_logger).not_to be(initial_default_logger)
          expect(actual_logger).to be(expected_logger)
        end

      end

      describe :new_default_logger do
        attr_reader :config

        before(:each) do
          app = Class.new(Rails::Application).new
          @config = app.config
        end

        it 'returns a file logger in test' do
          BerkeleyLibrary::Logging.env = 'test'
          logger = Loggers.new_default_logger(config)
          expect(logger).not_to be_nil
          logdev = logger.instance_variable_get(:@logdev)
          expect(logdev.filename).to end_with('log/test.log')
        end

        it 'returns a stdout logger in production' do
          BerkeleyLibrary::Logging.env = 'production'
          stdout_orig = $stdout
          stdout_tmp = StringIO.new
          begin
            $stdout = stdout_tmp
            logger = Loggers.new_default_logger(config)
          ensure
            $stdout = stdout_orig
          end
          expect(logger).not_to be_nil
          logdev = logger.instance_variable_get(:@logdev)
          expect(logdev.filename).to be_nil
          expect(logdev.dev).to eq(stdout_tmp)
        end

        it 'returns a stdout logger in development' do
          BerkeleyLibrary::Logging.env = 'development'
          logger = Loggers.new_default_logger(config)
          expect(logger).not_to be_nil
          logdev = logger.instance_variable_get(:@logdev)
          expect(logdev.filename).to be_nil
          expect(logdev.dev).to eq($stdout)

          # TODO: come up with a succinct way to test broadcast to file
        end
      end
    end
  end
end
