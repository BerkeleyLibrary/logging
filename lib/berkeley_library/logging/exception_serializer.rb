module BerkeleyLibrary
  module Logging
    module ExceptionSerializer
      def serialize_exc(ex, serialized = Set.new)
        raw_result = { name: ex.class.name, message: ex.message, stack: ex.backtrace }
        raw_result.tap do |result|
          next unless (cause = ex.cause)
          next if (serialized << ex).include?(cause) # prevent circular references

          result[:cause] = serialize_exc(cause, serialized)
        end
      end
    end
  end
end
