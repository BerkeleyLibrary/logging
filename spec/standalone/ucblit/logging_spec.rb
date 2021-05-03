require 'standalone_helper'

module UCBLIT
  describe Logging do

    def logger_defined?
      Logging.instance_variable_defined?(:@logger)
    end

    def reset_logger!
      Logging.instance_variable_set(:@logger, @logging_logger_orig)
    end

    def undefine_logger!
      Logging.send(:remove_instance_variable, :@logger) if logger_defined?
    end

    def new_mock_logger
      mock_logger_class = Class.new do
        def respond_to?(*args)
          %i[debug info warn error].include?(args[0].to_sym) || super
        end
      end

      mock_logger_class.new
    end

    before(:each) do
      if (@logger_was_defined = logger_defined?)
        @logging_logger_orig = Logging.instance_variable_get(:@logger)
        undefine_logger!
      end

      # Outside Rails, `default_logger` usually returns a new logger every time, so to make this
      # test simpler, we mock it to always return the same object
      persistent_default_logger = new_mock_logger
      allow(Logging::Loggers).to receive(:default_logger).and_return(persistent_default_logger)
    end

    after(:each) do
      @logger_was_defined ? reset_logger! : undefine_logger!
    end

    describe 'class methods' do
      describe :logger do
        it 'returns the default logger' do
          logger = Logging::Loggers.default_logger
          expect(Logging.logger).to eq(logger)
        end

        it 'returns a set logger' do
          logger = new_mock_logger
          Logging.logger = logger
          expect(Logging.logger).to be(logger)
        end

      end

      describe :logger= do
        it 'rejects a non-logger' do
          original_logger = Logging.logger
          expect { Logging.logger = Object.new }.to raise_error(ArgumentError)
          expect(Logging.logger).to eq(original_logger)
        end

        it 'can be reset to default with nil' do
          default_logger = Logging::Loggers.default_logger
          Logging.logger = new_mock_logger
          Logging.logger = nil
          expect(Logging.logger).to eq(default_logger)
        end
      end
    end

    describe 'included' do
      attr_reader :logificator

      before(:each) do
        @logificator = Object.new
        @logificator.singleton_class.include(Logging)
      end

      describe :logger do
        it 'returns the default logger' do
          logger = Logging::Loggers.default_logger
          expect(logificator.logger).to eq(logger)
        end

        it 'returns a set logger' do
          logger = new_mock_logger
          logificator.logger = logger
          expect(logificator.logger).to be(logger)
        end

        it 'returns a logger set via the class method' do
          logger = new_mock_logger
          Logging.logger = logger
          expect(logificator.logger).to be(logger)
        end
      end

      describe :logger= do
        it 'sets the shared logger via the class method' do
          logger = new_mock_logger
          logificator.logger = logger
          expect(Logging.logger).to be(logger)
        end

        it 'sets a shared logger accessible via another including class' do
          logger = new_mock_logger
          Object.new.tap do |logificator2|
            logificator2.singleton_class.send(:include, Logging)
            logificator2.logger = logger
          end
          expect(logificator.logger).to be(logger)
        end

        it 'rejects a non-logger' do
          original_logger = logificator.logger
          expect { logificator.logger = Object.new }.to raise_error(ArgumentError)
          expect(logificator.logger).to be(original_logger)
        end

        it 'can be reset to default with nil' do
          default_logger = Logging::Loggers.default_logger
          logificator.logger = new_mock_logger
          logificator.logger = nil
          expect(logificator.logger).to eq(default_logger)
        end
      end
    end
  end
end
