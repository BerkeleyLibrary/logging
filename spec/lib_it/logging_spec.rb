require 'spec_helper'
require 'rails'
require 'lograge'

module LibIT
  describe Logging do
    describe :configure! do

      attr_reader :config

      before(:each) do
        app = Class.new(Rails::Application).new
        allow(Rails).to receive(:application).and_return(app)
        @config = app.config

        config.lograge = Lograge::OrderedOptions.new
      end

      it 'sets the logger' do
        Logging.configure!
        expect(config.logger).to be_a(Logging::Loggers::AvLogger)
      end

      describe :configure_lograge! do
        it 'enables Lograge' do
          Logging.configure!
          lograge = config.lograge
          expect(lograge.enabled).to eq(true)
        end

        it 'extracts request info from log events' do
          Logging.configure!
          lograge = config.lograge

          request_headers = {
            'HTTP_REFERER' => 'value from HTTP_REFERER',
            'action_dispatch.request_id' => 'value from action_dispatch.request_id',
            'action_dispatch.remote_ip' => 'value from action_dispatch.remote_ip',
            'REMOTE_ADDR' => 'value from REMOTE_ADDR',
            'HTTP_X_FORWARDED_FOR' => 'value from HTTP_X_FORWARDED_FOR',
            'HTTP_FORWARDED' => 'value from HTTP_FORWARDED'
          }

          expected_header_map = {
            referer: 'HTTP_REFERER',
            request_id: 'action_dispatch.request_id',
            remote_ip: 'action_dispatch.remote_ip',
            remote_addr: 'REMOTE_ADDR',
            x_forwarded_for: 'HTTP_X_FORWARDED_FOR',
            forwarded: 'HTTP_FORWARDED'
          }

          event = instance_double(ActiveSupport::Notifications::Event)
          allow(event).to receive(:payload).and_return({ headers: request_headers })

          custom_options = lograge.custom_options
          data = custom_options.call(event)
          expect(data).to be_a(Hash)
          expect(data[:time]).to be_a(Time) # TODO: check for accuracy
          expected_header_map.each { |xh, rh| expect(data[xh]).to eq(request_headers[rh]) }
        end

        it 'formats Lograge data as a hash' do
          Logging.configure!
          lograge = config.lograge

          formatter = lograge.formatter
          expect(formatter.call(nil)).to eq({ msg: 'Request', request: {} })
          expect(formatter.call('elvis')).to eq({ msg: 'Request', request: { msg: 'elvis' } })
          some_hash = { foo: 'bar' }
          expect(formatter.call(some_hash)).to eq({ msg: 'Request', request: some_hash })
        end
      end

      describe 'Webpacker' do

        before(:each) do
          LibIT::Logging.remove_instance_variable(:@webpacker)
        end

        it 'works if Webpacker is not present' do
          expect { require 'webpacker/instance' }.to raise_error(LoadError) # just to be sure
          expect { Logging.configure! }.not_to raise_error
        end

        it 'sets the Webpacker logger if Webpacker is present' do
          module ::Webpacker
            module Instance
              class << self
                attr_accessor :logger
              end
            end
          end

          allow(LibIT::Logging).to receive(:require).with('webpacker/instance').and_return(true)
          expect(LibIT::Logging.send(:webpacker?)).to eq(true)

          Logging.configure!
          expect(Webpacker::Instance.logger).to eq(config.logger)
        ensure
          Object.send(:remove_const, :Webpacker) if Object.const_defined?(:Webpacker)
        end
      end
    end
  end
end
