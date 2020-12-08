require 'rspec/core/rake_task'

namespace :spec do
  desc 'Run all tests'
  RSpec::Core::RakeTask.new(:all) do |task|
    task.rspec_opts = %w[--color --format documentation --order default]
    task.pattern = 'spec/**/*_spec.rb'
  end
end

desc 'Run all tests'
task spec: ['spec:all']
