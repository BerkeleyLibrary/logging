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

        # rubocop:disable Lint/ConstantDefinitionInBlock
        it 'logs an error as a hash' do
          class ::TestError < StandardError; end

          begin
            out = StringIO.new

            msg = 'Help I am trapped in a unit test'

            begin
              raise TestError, msg
            rescue TestError => e
              ex = e
              Loggers.new_json_logger(out).error(e)
            end

            logged_json = JSON.parse(out.string)
            expect(logged_json['msg']).to eq(msg)
            err_json = logged_json['err']
            expect(err_json).to be_a(Hash)
            expect(err_json['name']).to eq(TestError.name)
            expect(err_json['message']).to eq(msg)

            err_stack = err_json['stack']
            backtrace = ex.backtrace
            expect(backtrace).not_to be_nil # just to be sure
            backtrace.each do |line|
              expect(err_stack).to include(line)
            end
          ensure
            Object.send(:remove_const, :TestError)
          end
        end
        # rubocop:enable Lint/ConstantDefinitionInBlock
      end

      describe :default_logger do
        it 'returns a readable $stdout logger' do
          logger = Loggers.default_logger
          expect(logger).to be_a(Logger)
          expect(logger.formatter).to be_a(Ougai::Formatters::Readable)

          logdev = logger.instance_variable_get(:@logdev)
          expect(logdev).to be_a(::Logger::LogDevice)
          expect(logdev.dev).to eq($stdout)
        end

        # rubocop:disable Lint/ConstantDefinitionInBlock
        it 'logs an error with cause and backtrace' do
          class ::TestError < StandardError; end

          begin
            out = StringIO.new

            msg = 'Help I am trapped in a unit test'

            begin
              raise TestError, msg
            rescue TestError => e
              ex = e
              Loggers.new_readable_logger(out).error(e)
            end

            logged_txt = out.string
            expect(logged_txt).to include(msg)
            expect(logged_txt).to include(TestError.name)
            backtrace = ex.backtrace
            expect(backtrace).not_to be_nil # just to be sure
            backtrace.each do |line|
              expect(logged_txt).to include(line)
            end
          ensure
            Object.send(:remove_const, :TestError)
          end
        end
        # rubocop:enable Lint/ConstantDefinitionInBlock

        it 'logs an arbitrary hash in a reasonable way' do
          out = StringIO.new
          msg_txt = 'message text'
          msg_h = {
            foo: 'Foo',
            bar: 'Bar',
            baz: 'Baz'
          }
          Loggers.new_readable_logger(out).info(msg_txt, msg_h)
          expect(out.string).to include(msg_txt)
          msg_h.each do |k, v|
            expect(out.string).to include(k.inspect)
            expect(out.string).to include(v.inspect)
          end
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
