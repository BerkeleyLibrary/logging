require 'spec_helper'

# ------------------------------------------------------------
# SimpleCov

SimpleCov.command_name('spec:standalone') if defined?(SimpleCov)

# ------------------------------------------------------------
# Code under test

require 'ucblit/logging'
