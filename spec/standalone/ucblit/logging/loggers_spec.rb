require 'standalone_helper'
require 'json'

module UCBLIT
  module Logging
    describe Loggers do
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
        it 'returns a readable $stdout logger' do
          logger = Loggers.default_logger
          expect(logger).to be_a(Logger)
          expect(logger.formatter).to be_a(Ougai::Formatters::Readable)

          logdev = logger.instance_variable_get(:@logdev)
          expect(logdev).to be_a(::Logger::LogDevice)
          expect(logdev.dev).to be($stdout)
        end
      end

      describe :new_default_logger do
        attr_reader :config

        before(:each) do
          @config = OpenStruct.new
        end

        after(:each) do
          UCBLIT::Logging.instance_variable_set(:@env, nil)
        end

        it 'returns a readable $stdout logger if given no config' do
          logger = Loggers.new_default_logger
          expect(logger).not_to be_nil
          expect(logger).to be_a(Logger)
          expect(logger.formatter).to be_a(Ougai::Formatters::Readable)
        end

        it 'returns a file logger in test' do
          UCBLIT::Logging.env = 'test'
          logger = Loggers.new_default_logger(config)
          expect(logger).not_to be_nil
          logdev = logger.instance_variable_get(:@logdev)
          expect(logdev.filename).to end_with('log/test.log')
        end

        it 'returns a stdout logger in production' do
          UCBLIT::Logging.env = 'production'
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
          UCBLIT::Logging.env = 'development'
          logger = Loggers.new_default_logger(config)
          expect(logger).not_to be_nil
          logdev = logger.instance_variable_get(:@logdev)
          expect(logdev.filename).to be_nil
          expect(logdev.dev).to eq($stdout)

          # TODO: come up with a succinct way to test broadcast to file
        end

        it 'fails on an unsupported environment' do
          UCBLIT::Logging.env = 'some-unsupported-environment'
          expect { Loggers.new_default_logger(config) }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
