require 'rspec/core/rake_task'

namespace :spec do
  test_groups = %i[standalone rails]

  test_groups.each do |group|
    desc "Run #{group} tests"
    RSpec::Core::RakeTask.new(group) do |task|
      task.rspec_opts = %w[--color --format documentation --order default]
      task.pattern = "spec/#{group}/**/*_spec.rb"
    end
  end

  multitask all: test_groups
end

desc 'Run all tests'
task spec: ['spec:all']
