require 'spec_helper'

# ------------------------------------------------------------
# Rails

require 'rails'
Rails.env = 'test'

# ------------------------------------------------------------
# SimpleCov

SimpleCov.command_name('spec:rails') if defined?(SimpleCov)

# ------------------------------------------------------------
# Code under test

require 'ucblit/logging'
