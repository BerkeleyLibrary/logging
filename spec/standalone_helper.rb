# ------------------------------------------------------------
# RSpec

require 'spec_helper'

# ------------------------------------------------------------
# RSpec

RSpec.configure do |config|
  config.around(:example) do |example|
    next example.run unless defined?(Rails)

    rails_orig = Object.send(:remove_const, :Rails)
    begin
      example.run
    ensure
      Object.const_set(:Rails, rails_orig)
    end
  end
end

# ------------------------------------------------------------
# Code under test

require 'berkeley_library/logging'
