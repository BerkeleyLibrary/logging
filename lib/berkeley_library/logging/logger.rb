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
