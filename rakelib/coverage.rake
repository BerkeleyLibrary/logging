require 'colorize'

namespace :simplecov do
  task :check_coverage do
    ENV['COVERAGE'] ||= 'true'
    Rake::Task['spec'].invoke
  rescue SystemExit
    puts 'Code coverage analysis aborted, probably due to a previous test failure'.colorize(:red)
    raise
  end

  task :report do
    require 'simplecov'
    require 'simplecov-rcov'
    require 'simplecov-console'

    result_sets = Dir.glob('artifacts/simplecov/**/.resultset.json')
    SimpleCov.collate(result_sets) do
      minimum_coverage 100
      coverage_dir 'artifacts'

      if ENV['GENERATE_REPORTS']
        formatters = [
          SimpleCov::Formatter::Console,
          SimpleCov::Formatter::RcovFormatter
        ]
        formatter SimpleCov::Formatter::MultiFormatter.new(formatters)
      else
        formatter SimpleCov::Formatter::Console
      end
    end
  end
end

desc 'Run all specs in spec directory, with coverage'
task coverage: %w[simplecov:check_coverage simplecov:report]
