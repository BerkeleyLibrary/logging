require 'active_support/tagged_logging'

# Monkey-patch ActiveSupport::TaggedLogging::Formatter
# not to produce garbage by prepending tags to hashes.
module ActiveSupport
  module TaggedLogging
    module Formatter
      def call(severity, time, progname, data)
        return super unless current_tags.present?

        original_data = Formatters.ensure_hash(data)
        merged_data = { tags: current_tags }.merge(original_data)
        super(severity, time, progname, merged_data)
      end
    end
  end
end
