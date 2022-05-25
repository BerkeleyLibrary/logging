require 'rails_helper'
require 'rails'
require 'lograge'
require 'berkeley_library/logging'

module BerkeleyLibrary
  module Logging
    describe Configurator do
      describe :configure! do

        attr_reader :config

        before do
          app = Class.new(Rails::Application).new
          allow(Rails).to receive(:application).and_return(app)
          @config = app.config

          config.lograge = Lograge::OrderedOptions.new
        end

        it 'sets the logger' do
          Configurator.configure(config)
          expect(config.logger).to be_a(Logging::Logger)
        end

        it 'returns the logger' do
          logger = Configurator.configure(config)
          expect(logger).to be(config.logger)
        end

        describe :configure_lograge! do
          it 'enables Lograge' do
            Configurator.configure(config)
            lograge = config.lograge
            expect(lograge.enabled).to eq(true)
          end

          context 'events' do
            let(:params) { { authenticity_token: '8675309' } }

            let(:session_hash) do
              {
                'session_id' => '17cd06b1b7cb9744e8fa626ef5f37c67',
                'user' => {
                  'id' => 71,
                  'user_name' => 'Ms. Magoo',
                  'created_at' => '2021-10-14T09:24:42.730-07:00',
                  'updated_at' => '2021-10-14T09:24:42.729-07:00',
                  'user_role' => 'Administrator',
                  'user_active' => true,
                  'uid' => 1_684_944,
                  'updated_by' => 'Dr. Pibb'
                },
                'expires_at' => '2021-11-03T12:30:01.281-07:00',
                '_csrf_token' => 'HiN1xUxFcOvWvoe2nwoBSGlmGSN6x0jprpSqDrzquxA='
              }
            end

            let(:request_headers) do
              {
                'HTTP_REFERER' => 'value from HTTP_REFERER',
                'action_dispatch.request_id' => 'value from action_dispatch.request_id',
                'action_dispatch.remote_ip' => 'value from action_dispatch.remote_ip',
                'REMOTE_ADDR' => 'value from REMOTE_ADDR',
                'HTTP_X_FORWARDED_FOR' => 'value from HTTP_X_FORWARDED_FOR',
                'HTTP_FORWARDED' => 'value from HTTP_FORWARDED'
              }
            end

            let(:expected_header_map) do
              {
                referer: 'HTTP_REFERER',
                request_id: 'action_dispatch.request_id',
                remote_ip: 'action_dispatch.remote_ip',
                remote_addr: 'REMOTE_ADDR',
                x_forwarded_for: 'HTTP_X_FORWARDED_FOR',
                forwarded: 'HTTP_FORWARDED'
              }
            end

            attr_reader :session, :request, :payload, :event

            before do
              @session = instance_double(ActionDispatch::Request::Session)
              allow(session).to receive(:to_hash).and_return(session_hash)

              @request = instance_double(ActionDispatch::Request)
              allow(request).to receive(:origin).and_return('http://example.org:3000')
              allow(request).to receive(:base_url).and_return('https://example.org:3443')
              allow(request).to receive(:x_csrf_token).and_return('5551212')
              allow(request).to receive(:session).and_return(session)

              @payload = {
                params: params,
                request: request,
                headers: request_headers
              }

              @event = instance_double(ActiveSupport::Notifications::Event)
              allow(event).to receive(:payload).and_return(payload)
            end

            it 'extracts request info from log events' do
              Configurator.configure(config)
              data = config.lograge.custom_options.call(event)

              expect(data).to be_a(Hash)
              expect(data[:time]).to be_a(Time)
              expect(data[:time].to_i).to be_within(60).of(Time.now.to_i)

              expected_header_map.each { |xh, rh| expect(data[xh]).to eq(request_headers[rh]) }

              expect(data[:authenticity_token]).to eq(params[:authenticity_token])

              Events::LOGGED_REQUEST_ATTRIBUTES.each do |attr|
                expect(data[attr]).to eq(request.send(attr))
              end
            end

            it 'includes the entire session if `verbose_session_logging` is true' do
              config.lograge.verbose_session_logging = true
              Configurator.configure(config)
              data = config.lograge.custom_options.call(event)

              expect(data[:session]).to eq(session_hash)
            end

            it 'includes only the session ID by default' do
              Configurator.configure(config)
              data = config.lograge.custom_options.call(event)

              expected_hash = Events::LOGGED_SESSION_ATTRIBUTES.each_with_object({}) do |attr, h|
                h[attr] = session_hash[attr.to_s]
              end

              expect(data[:session]).to eq(expected_hash)
            end
          end

          it 'formats Lograge data as a hash' do
            Configurator.configure(config)
            lograge = config.lograge

            formatter = lograge.formatter
            expect(formatter.call(nil)).to eq({ msg: 'Request', request: {} })
            expect(formatter.call('elvis')).to eq({ msg: 'Request', request: { msg: 'elvis' } })
            some_hash = { foo: 'bar' }
            expect(formatter.call(some_hash)).to eq({ msg: 'Request', request: some_hash })
          end
        end

        describe 'Webpacker' do
          it 'works if Webpacker is not present' do
            expect(Object.const_defined?(:Webpacker)).to eq(false) # just to be sure
            expect { Configurator.configure(config) }.not_to raise_error
          end

          it 'sets the Webpacker logger if Webpacker is present' do
            module ::Webpacker
              module Instance
                class << self
                  attr_accessor :logger
                end
              end
            end

            Configurator.configure(config)
            expect(Webpacker::Instance.logger).to eq(config.logger)
          ensure
            Object.send(:remove_const, :Webpacker) if defined?(Webpacker)
          end
        end
      end
    end
  end
end
