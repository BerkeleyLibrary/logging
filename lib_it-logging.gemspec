File.expand_path('lib', __dir__).tap do |lib|
  $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
end

ruby_version_file = File.expand_path('.ruby-version', __dir__)
ruby_version = File.read(ruby_version_file).strip

require 'lib_it/logging/module_info'

Gem::Specification.new do |spec|
  spec.name = LibIT::Logging::ModuleInfo::NAME
  spec.author = LibIT::Logging::ModuleInfo::AUTHOR
  spec.email = LibIT::Logging::ModuleInfo::AUTHOR_EMAIL
  spec.summary = LibIT::Logging::ModuleInfo::SUMMARY
  spec.description = LibIT::Logging::ModuleInfo::DESCRIPTION
  spec.license = LibIT::Logging::ModuleInfo::LICENSE
  spec.version = LibIT::Logging::ModuleInfo::VERSION
  spec.homepage = LibIT::Logging::ModuleInfo::HOMEPAGE

  spec.files = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = ">= #{ruby_version}"

  spec.add_dependency 'amazing_print', '~> 1.1'
  spec.add_dependency 'lograge', '~> 0.11'
  spec.add_dependency 'ougai', '~> 1.8'
  spec.add_dependency 'rails', '~> 6.0'

  spec.add_development_dependency 'brakeman', '~> 4.9'
  spec.add_development_dependency 'bundle-audit', '~> 0.1'
  spec.add_development_dependency 'ci_reporter_rspec', '~> 1.0'
  spec.add_development_dependency 'colorize', '~> 0.8'
  spec.add_development_dependency 'dotenv', '~> 2.7'
  spec.add_development_dependency 'irb', '~> 1.2' # workaroundfor https://github.com/bundler/bundler/issues/6929
  spec.add_development_dependency 'listen', '>= 3.0.5', '< 3.2'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec-support', '~> 3.9'
  spec.add_development_dependency 'rubocop', '~> 0.91.0'
  spec.add_development_dependency 'simplecov', '~> 0.16.1'
  spec.add_development_dependency 'simplecov-rcov', '~> 0.2'
end
