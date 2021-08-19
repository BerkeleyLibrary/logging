require 'standalone_helper'
require 'json'

module BerkeleyLibrary
  module Logging
    describe Loggers do
      attr_reader :out

      # rubocop:disable Lint/ConstantDefinitionInBlock
      before(:each) do
        @out = StringIO.new
        class ::TestError < StandardError; end
      end
      # rubocop:enable Lint/ConstantDefinitionInBlock

      after(:each) do
        Object.send(:remove_const, :TestError)
      end

      describe :new_json_logger do
        it 'supports tagged logging' do
          logger = Loggers.new_json_logger(out)
          logger = ActiveSupport::TaggedLogging.new(logger)

          expected_tag = 'hello'
          expected_msg = 'this is a test'

          logger.tagged(expected_tag) { logger.info(expected_msg) }

          logged_json = JSON.parse(out.string)
          expect(logged_json['msg']).to eq(expected_msg)
          expect(logged_json['tags']).to eq([expected_tag])
        end

        it 'logs an error as a hash' do
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
        end
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

        describe 'errors' do
          it 'logs an error alone with cause and backtrace' do
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
          end

        end

        describe 'messages with text and data' do
          it 'logs an arbitrary hash in a reasonable way' do
            out = StringIO.new
            msg_txt = 'message text'
            msg_h = {
              foo: 'Foo',
              bar: 'Bar',
              baz: 'Baz'
            }
            Loggers.new_readable_logger(out).info(msg_txt, msg_h)

            logged_txt = out.string
            expect(logged_txt).to include(msg_txt)
            msg_h.each do |k, v|
              expect(logged_txt).to include(k.inspect)
              expect(logged_txt).to include(v.inspect)
            end
          end

          it 'logs something with #to_hash as a hash' do
            out = StringIO.new
            msg_txt = 'message text'
            msg_h = {
              foo: 'Foo',
              bar: 'Bar',
              baz: 'Baz'
            }
            msg_obj = Object.new
            msg_obj.singleton_class.define_method(:to_hash) { msg_h }

            Loggers.new_readable_logger(out).info(msg_txt, msg_obj)

            logged_txt = out.string
            expect(logged_txt).to include(msg_txt)
            msg_h.each do |k, v|
              expect(logged_txt).to include(k.inspect)
              expect(logged_txt).to include(v.inspect)
            end
          end

          it 'logs an error with cause and backtrace' do
            msg_txt = 'message text'
            ex_msg = 'Help I am trapped in a unit test'

            begin
              raise TestError, ex_msg
            rescue TestError => e
              ex = e
              Loggers.new_readable_logger(out).error(msg_txt, e)
            end

            logged_txt = out.string
            expect(logged_txt).to include(msg_txt)
            expect(logged_txt).to include(ex_msg)
            expect(logged_txt).to include(TestError.name)
            backtrace = ex.backtrace
            expect(backtrace).not_to be_nil # just to be sure
            backtrace.each do |line|
              expect(logged_txt).to include(line)
            end
          end

        end

        describe 'messages with data and no text' do
          it 'logs an arbitrary hash in a reasonable way' do
            out = StringIO.new
            msg_h = {
              foo: 'Foo',
              bar: 'Bar',
              baz: 'Baz'
            }
            Loggers.new_readable_logger(out).info(msg_h)
            logged_txt = out.string
            msg_h.each do |k, v|
              expect(logged_txt).to include(k.inspect)
              expect(logged_txt).to include(v.inspect)
            end
          end

          it 'logs something with #to_hash as a hash' do
            out = StringIO.new
            msg_h = {
              foo: 'Foo',
              bar: 'Bar',
              baz: 'Baz'
            }
            msg_obj = Object.new
            msg_obj.singleton_class.define_method(:to_hash) { msg_h }

            Loggers.new_readable_logger(out).info(msg_obj)

            logged_txt = out.string
            msg_h.each do |k, v|
              expect(logged_txt).to include(k.inspect)
              expect(logged_txt).to include(v.inspect)
            end
          end

          it 'logs an error with cause and backtrace' do
            ex_msg = 'Help I am trapped in a unit test'

            begin
              raise TestError, ex_msg
            rescue TestError => e
              ex = e
              Loggers.new_readable_logger(out).error(e)
            end

            logged_txt = out.string
            expect(logged_txt).to include(ex_msg)
            expect(logged_txt).to include(TestError.name)
            backtrace = ex.backtrace
            expect(backtrace).not_to be_nil # just to be sure
            backtrace.each do |line|
              expect(logged_txt).to include(line)
            end
          end

        end

      end

      describe :new_default_logger do
        attr_reader :config

        before(:each) do
          @config = OpenStruct.new
        end

        after(:each) do
          BerkeleyLibrary::Logging.instance_variable_set(:@env, nil)
        end

        it 'returns a readable $stdout logger if given no config' do
          logger = Loggers.new_default_logger
          expect(logger).not_to be_nil
          expect(logger).to be_a(Logger)
          expect(logger.formatter).to be_a(Ougai::Formatters::Readable)
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

        it 'fails on an unsupported environment' do
          BerkeleyLibrary::Logging.env = 'some-unsupported-environment'
          expect { Loggers.new_default_logger(config) }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
