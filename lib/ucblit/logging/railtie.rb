require 'lograge'
require 'ucblit/logging/configurator'

module UCBLIT
  module Logging
    class Railtie < Lograge::Railtie
      # Work around https://github.com/roidrage/lograge/issues/321
      Rails::Railtie.subclasses.delete(Lograge::Railtie)
      Rails::Railtie.subclasses << self

      # Don't use the Railtie's own config because configure() needs
      # Rails::Application::Configuration#default_log_file
      initializer('logging.configure_ucblit_logging', before: :initialize_logger) do |app|
        Configurator.configure(app.config)
      end
    end
  end
end
