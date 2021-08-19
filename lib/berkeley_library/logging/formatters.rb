require 'ougai'

module BerkeleyLibrary
  module Logging
    module Formatters

      class << self
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
