require 'lograge'
require 'lograge/railtie' # NOTE: registers Lograge::Railtie by side effect
require 'ucblit/logging/configurator'

module UCBLIT
  module Logging
    class Railtie < Rails::Railtie
      # Don't use the Railtie's own `config` because configure() needs
      # Rails::Application::Configuration#default_log_file
      initializer('logging.configure_ucblit_logging', before: :initialize_logger) do |app|
        Configurator.configure(app.config)
      end
    end
  end
end
