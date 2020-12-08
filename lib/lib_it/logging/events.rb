module LibIT
  module Logging
    module Events
      class << self
        def extract_data_for_lograge
          ->(event) { extract_event_data(event) }
        end

        private

        def extract_event_data(event)
          event_data = { time: Time.now }
          extracted_headers = extract_headers(event)
          event_data.merge(extracted_headers)
        end

        def extract_headers(event)
          return {} unless (headers = event.payload[:headers])

          extracted_headers = {
            # yes, RFC 2616 uses a variant spelling for 'referrer', it's a known issue
            # https://tools.ietf.org/html/rfc2616#section-14.36
            referer: headers['HTTP_REFERER'],
            request_id: headers['action_dispatch.request_id'],
            remote_ip: headers['action_dispatch.remote_ip'],
            remote_addr: headers['REMOTE_ADDR'],
            x_forwarded_for: headers['HTTP_X_FORWARDED_FOR'],
            forwarded: headers['HTTP_FORWARDED'] # RFC 7239
          }

          # Some of these 'headers' include recursive structures
          # that cause SystemStackErrors in JSON serialization,
          # so we convert them all to strings
          extracted_headers.transform_values(&:to_s)
        end
      end
    end
  end
end
