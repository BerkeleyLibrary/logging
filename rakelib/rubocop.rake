require 'rubocop'
require 'rubocop/rake_task'

desc 'Run RuboCop'
RuboCop::RakeTask.new(:rubocop) do |cop|
  next unless ENV['GENERATE_REPORTS']

  output = ENV['RUBOCOP_OUTPUT'] || 'artifacts/rubocop/index.html'
  puts "Writing RuboCop inspection report to #{output}"

  cop.verbose = false
  cop.formatters = ['html']
  cop.options = ['--out', output]
end
