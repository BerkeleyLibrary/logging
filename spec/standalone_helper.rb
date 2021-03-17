require 'spec_helper'

# ------------------------------------------------------------
# SimpleCov

SimpleCov.command_name('spec:standalone') if defined?(SimpleCov)

# ------------------------------------------------------------
# RSpec

RSpec.configure do |config|
  config.around(:example) do |example|
    next example.run unless defined?(Rails)

    rails_orig = Rails
    Object.send(:remove_const, :Rails)
    begin
      example.run
    ensure
      Object.const_set(:Rails, rails_orig)
    end
  end
end

# ------------------------------------------------------------
# Code under test

require 'ucblit/logging'
