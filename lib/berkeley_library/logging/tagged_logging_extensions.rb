require 'active_support/tagged_logging'
require 'berkeley_library/logging/formatters'

# Monkey-patch ActiveSupport::TaggedLogging::Formatter
# not to produce garbage by prepending tags to hashes.
#
# TODO: Can we intercept Formatter.extend() instead? See
# https://github.com/rails/rails/blob/v6.0.3.4/activesupport/lib/active_support/tagged_logging.rb#L73
module ActiveSupport
  module TaggedLogging
    module Formatter
      def call(severity, time, progname, data)
        return super unless current_tags.present?

        original_data = BerkeleyLibrary::Logging::Formatters.ensure_hash(data)
        merged_data = { tags: current_tags }.merge(original_data)
        super(severity, time, progname, merged_data)
      end
    end
  end
end
