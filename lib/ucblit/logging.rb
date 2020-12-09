if defined?(Rails)
  require 'ucblit/logging/railtie'
else
  require 'ucblit/logging/configurator'
end
