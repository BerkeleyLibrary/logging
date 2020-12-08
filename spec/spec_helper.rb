# ------------------------------------------------------------
# Simplecov

require 'colorize'
require 'simplecov' if ENV['COVERAGE']

# ------------------------------------------------------------
# RSpec

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.formatter = :documentation
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
end

# ------------------------------------------------------------
# Code under test

require 'lib_it/logging'
