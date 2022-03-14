# ------------------------------------------------------------
# SimpleCov

if ENV['COVERAGE']
  require 'simplecov'

  spec_root = File.realpath(__dir__)
  spec_group_re = %r{(?<=^#{spec_root}/)[^/]+(?=/)}

  RSpec.configure do |config|
    config.before do |example|
      abs_path = File.realpath(example.metadata[:absolute_file_path])
      match_data = spec_group_re.match(abs_path)
      raise ArgumentError, "Unable to determine group for example at #{abs_path}" unless match_data

      spec_group = match_data[0]
      SimpleCov.command_name(spec_group)
      SimpleCov.coverage_dir("artifacts/simplecov/#{spec_group}")
    end
  end
end

# ------------------------------------------------------------
# RSpec

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.formatter = :documentation
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
end
