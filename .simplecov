SimpleCov.start 'rails' do
  add_filter 'module_info.rb'

  if ENV['GITHUB_ACTION']
    formatter SimpleCov::Formatter::SimpleFormatter
  else
    # TODO: figure out why this doesn't work in CI
    require 'simplecov-rcov'
    coverage_dir 'artifacts'

    SimpleCov.collate Dir['artifacts/simplecov/**/.resultset.json'] do
      formatter SimpleCov::Formatter::RcovFormatter
    end
  end
end
