module BerkeleyLibrary
  module Logging
    module Events
      class << self
        LOGGED_REQUEST_ATTRIBUTES = %i[origin base_url x_csrf_token].freeze
        LOGGED_PARAMETERS = [:authenticity_token].freeze
        LOGGED_HEADERS = {
          # yes, RFC 2616 uses a variant spelling for 'referrer', it's a known issue
          # https://tools.ietf.org/html/rfc2616#section-14.36
          referer: 'HTTP_REFERER',
          request_id: 'action_dispatch.request_id',
          remote_ip: 'action_dispatch.remote_ip',
          remote_addr: 'REMOTE_ADDR',
          x_forwarded_for: 'HTTP_X_FORWARDED_FOR',
          forwarded: 'HTTP_FORWARDED' # RFC 7239
        }.freeze

        def extract_data_for_lograge
          ->(event) { extract_event_data(event) }
        end

        private

        def extract_event_data(event)
          { time: Time.now }.tap do |event_data|
            headers = extract_headers(event)
            event_data.merge!(headers)

            request_attributes = extract_request_attributes(event)
            event_data.merge!(request_attributes)

            param_values = extract_param_values(event)
            event_data.merge!(param_values)
          end
        end

        def extract_param_values(event)
          return {} unless (params = event.payload[:params])

          LOGGED_PARAMETERS.each_with_object({}) do |param, values|
            next unless (param_val = params[param])

            values[param] = param_val
          end
        end

        def extract_request_attributes(event)
          return {} unless (request = event.payload[:request])

          LOGGED_REQUEST_ATTRIBUTES.each_with_object({}) do |attr, values|
            next unless request.respond_to?(attr)
            next unless (attr_val = request.send(attr))

            values[attr] = attr_val
          end
        end

        def extract_headers(event)
          return {} unless (headers = event.payload[:headers])

          LOGGED_HEADERS.each_with_object({}) do |(key, header), values|
            next unless (header_val = headers[header])

            # Some of these 'headers' include recursive structures
            # that cause SystemStackErrors in JSON serialization,
            # so we convert them all to strings
            values[key] = header_val.to_s
          end
        end
      end
    end
  end
end
