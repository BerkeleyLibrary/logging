require 'ougai'

module BerkeleyLibrary
  module Logging
    module Formatters

      class << self

        # See https://stackoverflow.com/a/14693789/27358
        ANSI_7C1_RE = %r{\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])}.freeze

        def new_json_formatter
          Bunyan.new
        end

        def new_readable_formatter
          Readable.new
        end

        def lograge_formatter
          ->(data) { { msg: 'Request', request: Formatters.ensure_hash(data) } }
        end

        def ensure_hash(message)
          return {} unless message
          return message if message.is_a?(Hash)

          { msg: message }
        end

        def strip_ansi_escapes(message)
          return unless message
          return message.gsub(ANSI_7C1_RE, '') if message.is_a?(String)
          return message.map { |v| strip_ansi_escapes(v) } if message.is_a?(Array)
          return message.transform_values { |v| strip_ansi_escapes(v) } if message.is_a?(Hash)

          message
        end
      end

      # ------------------------------------------------------------
      # Private helper classes

      module ErrorCauseSerializer
        def serialize_exc(ex, serialized = Set.new)
          super(ex).tap do |result|
            next unless (cause = ex.cause)
            next if (serialized << ex).include?(cause) # prevent circular references

            result[:cause] = serialize_exc(cause, serialized)
          end
        end
      end

      private_constant :ErrorCauseSerializer

      class Readable < Ougai::Formatters::Readable
        include ErrorCauseSerializer

        protected

        def create_err_str(data)
          return unless (err_hash = data.delete(:err))

          format_err(err_hash)
        end

        private

        def format_err(err_hash)
          "  #{err_hash[:name]} (#{err_hash[:message]}):".tap do |msg|
            next unless (stack = err_hash[:stack])

            msg << "\n"
            msg << (' ' * @trace_indent)
            msg << stack

            next unless (cause_hash = err_hash[:cause])

            msg << "\n  Caused by: "
            msg << format_err(cause_hash).strip
          end
        end

      end
      private_constant :Readable

      class Bunyan < Ougai::Formatters::Bunyan
        include Ougai::Logging::Severity
        include ErrorCauseSerializer

        def _call(severity, time, progname, data)
          original_data = Formatters.ensure_hash(data)
          decolorized_data = Formatters.strip_ansi_escapes(original_data)

          # Ougai::Formatters::Bunyan replaces the human-readable severity string
          # with a numeric level, so we add it here as a separate attribute
          severity = ensure_human_readable(severity)
          merged_data = { severity: severity }.merge(decolorized_data)
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
