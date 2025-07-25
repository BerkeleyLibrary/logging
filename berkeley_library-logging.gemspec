File.expand_path('lib', __dir__).tap do |lib|
  $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
end

ruby_version = begin
  ruby_version_file = File.expand_path('.ruby-version', __dir__)
  File.read(ruby_version_file).strip
end

require 'berkeley_library/logging/module_info'

Gem::Specification.new do |spec|
  spec.name = BerkeleyLibrary::Logging::ModuleInfo::NAME
  spec.author = BerkeleyLibrary::Logging::ModuleInfo::AUTHORS
  spec.email = BerkeleyLibrary::Logging::ModuleInfo::AUTHOR_EMAILS
  spec.summary = BerkeleyLibrary::Logging::ModuleInfo::SUMMARY
  spec.description = BerkeleyLibrary::Logging::ModuleInfo::DESCRIPTION
  spec.license = BerkeleyLibrary::Logging::ModuleInfo::LICENSE
  spec.version = BerkeleyLibrary::Logging::ModuleInfo::VERSION
  spec.homepage = BerkeleyLibrary::Logging::ModuleInfo::HOMEPAGE

  spec.files = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']

  spec.required_ruby_version = ruby_version

  rails_version = '>= 7'

  spec.add_dependency 'activesupport', rails_version
  spec.add_dependency 'amazing_print', '~> 1.1'
  spec.add_dependency 'colorize', '~> 1.0'
  spec.add_dependency 'lograge', '~> 0.11'
  spec.add_dependency 'ougai', '~> 2.0'

  spec.add_development_dependency 'brakeman', '~> 4.9'
  spec.add_development_dependency 'bundle-audit', '~> 0.1'
  spec.add_development_dependency 'ci_reporter_rspec', '~> 1.0'
  spec.add_development_dependency 'dotenv', '~> 2.7'
  spec.add_development_dependency 'listen', '~> 3.2'
  spec.add_development_dependency 'rails', rails_version
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'rubocop', '~> 1.78.0'
  spec.add_development_dependency 'rubocop-rake', '~> 0.7.1'
  spec.add_development_dependency 'rubocop-rspec', '~> 3.6.0'
  spec.add_development_dependency 'simplecov', '~> 0.21'
  spec.add_development_dependency 'simplecov-console', '~> 0.9'
  spec.add_development_dependency 'simplecov-rcov', '~> 0.2'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
