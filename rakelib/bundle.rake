namespace :bundle do
  desc 'Check bundled gems for vulnerabilities against the latest ruby-advisory-db'
  task :audit do
    require 'bundler/audit/cli'
    Bundler::Audit::CLI.start ['update']
    Bundler::Audit::CLI.start %w[check --ignore CVE-2015-9284]
  end
end
