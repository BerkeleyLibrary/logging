ENV['BUNDLE_GEMFILE'] ||= File.expand_path('Gemfile', __dir__)
require 'bundler/setup' # Set up gems listed in the Gemfile.

# ------------------------------------------------------------
# Application code

File.expand_path('lib', __dir__).tap do |lib|
  $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
end

# ------------------------------------------------------------
# CI

if ENV['CI']
  ENV['RAILS_ENV'] = 'test'
  ENV['GENERATE_REPORTS'] ||= 'true'
end

# ------------------------------------------------------------
# Custom tasks

desc 'Remove artifacts directory'
task :clean do
  FileUtils.rm_rf('artifacts')
end

desc 'Check test coverage, check code style, check gems for vulnerabilities'
task check: %w[coverage rubocop bundle:audit]

desc 'Clean, check, build gem'
task default: %i[clean check gem]
