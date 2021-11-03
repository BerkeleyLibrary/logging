require 'time'
require 'berkeley_library/logging/exception_serializer'

module BerkeleyLibrary
  module Logging
    # Some of values include recursive structures
    # that cause SystemStackErrors in JSON serialization,
    # so we convert them all to strings
    class SafeSerializer
      include ExceptionSerializer

      RAW_TYPES = [NilClass, FalseClass, TrueClass, Numeric, String, Symbol, Date, Time].freeze

      def initialize(value)
        @value = value
      end

      class << self
        def serialize(value)
          SafeSerializer.new(value).serialized_value
        end

        def placeholder_for(value)
          "#<#{value.class}:#{value.object_id}> (recursive reference)"
        end
      end

      def serialized_value
        @serialized_value ||= serialize(@value)
      end

      private

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      def serialize(value)
        return value if safe_raw_value?(value)
        return SafeSerializer.placeholder_for(value) if serialized_values.include?(value)

        serialized_values << value

        return serialize_hash(value) if value.is_a?(Hash)
        return serialize_hash(value.to_hash) if value.respond_to?(:to_hash)
        return serialize_array(value) if value.is_a?(Array)
        return serialize_array(value.to_ary) if value.respond_to?(:to_ary)
        return serialize_exc(value, serialized_values) if value.is_a?(Exception)

        value.to_s
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

      def safe_raw_value?(value)
        return true if rails_time_with_zone?(value)

        RAW_TYPES.any? { |t| value.is_a?(t) }
      end

      def rails_time_with_zone?(value)
        defined?(ActiveSupport::TimeWithZone) && value.is_a?(ActiveSupport::TimeWithZone)
      end

      def serialize_array(value)
        value.map { |v| serialize(v) }
      end

      def serialize_hash(value)
        value.each_with_object({}) do |(k, v), h|
          k1, v1 = [k, v].map { |x| serialize(x) }
          h[k1] = v1
        end
      end

      def serialized_values
        @serialized_values ||= Set.new
      end
    end
  end
end
