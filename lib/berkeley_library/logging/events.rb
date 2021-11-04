require 'berkeley_library/logging/safe_serializer'

module BerkeleyLibrary
  module Logging
    module Events
      LOGGED_REQUEST_ATTRIBUTES = %i[origin base_url x_csrf_token].freeze
      LOGGED_SESSION_ATTRIBUTES = %i[session_id _csrf_token].freeze
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

      class << self

        def extract_data_for_lograge(lograge_config)
          verbose_session_logging = lograge_config.verbose_session_logging

          ->(event) { extract_event_data(event.payload, verbose_session_logging) }
        end

        private

        def extract_event_data(payload, verbose_session_logging)
          [
            extract_headers(payload),
            extract_request_attributes(payload),
            extract_param_values(payload),
            extract_session(payload, verbose_session_logging)
          ].inject({ time: Time.now }) do |data, values|
            clean_values = SafeSerializer.serialize(values)
            data.merge(clean_values)
          end
        end

        def extract_param_values(payload)
          return {} unless (params = payload[:params])

          LOGGED_PARAMETERS.each_with_object({}) do |param, values|
            next unless (param_val = params[param])

            values[param] = param_val
          end
        end

        def extract_request_attributes(payload)
          return {} unless (request = payload[:request])

          LOGGED_REQUEST_ATTRIBUTES.each_with_object({}) do |attr, values|
            next unless request.respond_to?(attr)
            next if (attr_val = request.send(attr)).nil?

            values[attr] = attr_val
          end
        end

        def extract_headers(payload)
          return {} unless (headers = payload[:headers])

          LOGGED_HEADERS.each_with_object({}) do |(key, header), values|
            next unless (header_val = headers[header])

            values[key] = header_val
          end
        end

        def extract_session(payload, verbose_session_logging)
          return {} unless (request = payload[:request])
          return {} unless (session = request.session)
          return {} unless session.respond_to?(:to_hash)

          session_hash = session_hash(session, verbose_session_logging)

          { session: session_hash }
        end

        def session_hash(session, verbose)
          raw_session_hash = session.to_hash
          return raw_session_hash if verbose

          LOGGED_SESSION_ATTRIBUTES.filter_map do |attr|
            attr_str = attr.to_s
            [attr, raw_session_hash[attr_str]] if raw_session_hash.key?(attr_str)
          end.to_h
        end
      end
    end
  end
end
