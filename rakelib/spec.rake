require 'rspec/core/rake_task'

namespace :spec do
  task :prepare do
    if ENV['GENERATE_REPORTS']
      ENV['CI_REPORTS'] = 'artifacts/rspec'

      require 'ci/reporter/rake/rspec'
      Rake::Task['ci:setup:rspec'].invoke
    end
  end

  test_groups = %i[standalone rails].tap do |groups|
    groups.each do |group|
      desc "Run specs in spec/#{group} directory"
      RSpec::Core::RakeTask.new(group) do |task|
        task.rspec_opts = %w[--color --format documentation --order default]
        task.pattern = "spec/#{group}/**/*_spec.rb"
      end
    end
  end
  multitask all: test_groups
end

desc 'Run all specs in spec directory'
task spec: ['spec:prepare'] do
  Rake::Task['spec:all'].invoke
ensure
  reports_dir = ENV['CI_REPORTS']
  puts "JUnit-format XML test report written to #{reports_dir}" if reports_dir
end
