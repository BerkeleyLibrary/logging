begin
  # Rails 7.x LoggerThreadSafeLevel needs IsolatedExecutionState,
  # but doesn't explicitly require it
  require 'active_support/isolated_execution_state'
rescue LoadError
  # Rails 6.x doesn't
end

require 'active_support/logger'
require 'ougai'
require 'berkeley_library/logging/tagged_logging_extensions'

module BerkeleyLibrary
  module Logging
    class Logger < Ougai::Logger
      include ActiveSupport::LoggerThreadSafeLevel
      include ActiveSupport::LoggerSilence
    end
  end
end
