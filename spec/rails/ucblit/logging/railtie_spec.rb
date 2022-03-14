require 'rails_helper'

module BerkeleyLibrary
  module Logging
    describe Railtie do
      attr_reader :app
      attr_reader :config

      before do
        @app = Class.new(Rails::Application).new
        allow(Rails).to receive(:application).and_return(app)
        @config = app.config
      end

      describe 'initializer' do
        attr_reader :logging_initializer
        attr_reader :bootstrap_logger_initializer

        before do
          expected_file, _line = Module.const_source_location(BerkeleyLibrary::Logging::Railtie.name)
          @logging_initializer = app.initializers.find do |init|
            block = init.block
            file, _line = block.source_location
            file == expected_file
          end
          @bootstrap_logger_initializer = app.initializers.find { |init| init.name == :initialize_logger }
        end

        it 'is added to the Rails application' do
          expect(logging_initializer).not_to be_nil
        end

        it 'runs before the bootstrap logger initializer' do
          expect(logging_initializer.before).to eq(bootstrap_logger_initializer.name)
        end

        it 'sets the logger' do
          logging_initializer.run(app)
          bootstrap_logger_initializer.run(app)

          expect(Rails.logger).to be_a(BerkeleyLibrary::Logging::Logger)
        end
      end
    end
  end
end
