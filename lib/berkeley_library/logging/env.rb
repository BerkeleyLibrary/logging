require 'active_support/string_inquirer'

module BerkeleyLibrary
  module Logging
    class << self
      FALLBACK_ENV = 'development'.freeze
      ENV_PREDICATES = %i[production? test? development?].freeze
      private_constant :ENV_PREDICATES

      def env
        return Rails.env if defined?(Rails)

        @env ||= begin
          # Note: can't just self.env= b/c it returns the wrong value -- see
          # https://stackoverflow.com/q/65226532/27358
          env = (ENV['RAILS_ENV'] || ENV['RACK_ENV'] || FALLBACK_ENV)
          ensure_rails_env_like(env)
        end
      end

      def env=(v)
        if defined?(Rails)
          Rails.env = v
        else
          @env = ensure_rails_env_like(v)
        end
      end

      private

      def ensure_rails_env_like(v)
        return v if ENV_PREDICATES.all? { |p| v.respond_to?(p) }

        ActiveSupport::StringInquirer.new(v)
      end
    end
  end
end
