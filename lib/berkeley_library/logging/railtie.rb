require 'lograge'
require 'lograge/railtie' # NOTE: registers Lograge::Railtie by side effect
require 'berkeley_library/logging/configurator'

module BerkeleyLibrary
  module Logging
    class Railtie < Rails::Railtie
      # Don't use the Railtie's own `config` because configure() needs
      # Rails::Application::Configuration#default_log_file
      initializer('logging.configure_berkeley_library_logging', before: :initialize_logger) do |app|
        Configurator.configure(app.config)
      end
    end
  end
end
