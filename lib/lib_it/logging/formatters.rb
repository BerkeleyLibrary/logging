require 'ougai'

module LibIT
  module Logging
    module Formatters

      class << self
        def new_json_formatter
          Bunyan.new
        end

        def new_readable_formatter
          Ougai::Formatters::Readable.new
        end

        def lograge_formatter
          ->(data) { { msg: 'Request', request: Formatters.ensure_hash(data) } }
        end

        def ensure_hash(message)
          return {} unless message
          return message if message.is_a?(Hash)

          { msg: message }
        end
      end

      # ------------------------------------------------------------
      # Private helper classes

      class Bunyan < Ougai::Formatters::Bunyan
        include Ougai::Logging::Severity

        def _call(severity, time, progname, data)
          original_data = Formatters.ensure_hash(data)

          # Ougai::Formatters::Bunyan replaces the human-readable severity string
          # with a numeric level, so we add it here as a separate attribute
          severity = ensure_human_readable(severity)
          merged_data = { severity: severity }.merge(original_data)
          super(severity, time, progname, merged_data)
        end

        def ensure_human_readable(severity)
          return to_label(severity) if severity.is_a?(Integer)

          severity.to_s
        end
      end

      private_constant :Bunyan
    end
  end
end
