require 'lograge'
require 'ucblit/logging/configurator'

module UCBLIT
  module Logging
    class Railtie < Lograge::Railtie
      # Don't use the Railtie's own config because we need Rails::Application::Configuration#default_log_file
      initializer('logging.configure_ucblit_logging', after: :initialize_logger) do |app|
        Configurator.configure(app.config)
      end
    end
  end
end
