require 'active_support/logger'
require 'ougai'
require 'ucblit/logging/tagged_logging_extensions'

module UCBLIT
  module Logging
    class Logger < Ougai::Logger
      include ActiveSupport::LoggerThreadSafeLevel
      include ActiveSupport::LoggerSilence
    end
  end
end
