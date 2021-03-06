require 'rubygems/gem_runner'
require 'berkeley_library/logging/module_info'

module BerkeleyLibrary
  module Logging
    class << self
      def project_root
        @project_root ||= File.expand_path('..', __dir__)
      end

      def artifacts_dir
        return project_root unless ENV['CI']

        @artifacts_dir ||= File.join(project_root, 'artifacts')
      end

      def gemspec_file
        @gemspec_file ||= begin
          gemspec_files = Dir.glob(File.expand_path('*.gemspec', project_root))
          raise ArgumentError, "Too many .gemspecs: #{gemspec_files.join(', ')}" if gemspec_files.size > 1
          raise ArgumentError, 'No .gemspec file found' if gemspec_files.empty?

          gemspec_files[0]
        end
      end

      def gemspec_basename
        File.basename(gemspec_file)
      end

      def output_file
        @output_file ||= begin
          gem_name = File.basename(gemspec_file, '.*')
          version = BerkeleyLibrary::Logging::ModuleInfo::VERSION
          basename = "#{gem_name}-#{version}.gem"
          File.join(artifacts_dir, basename)
        end
      end

      def output_file_relative
        return File.basename(output_file) unless ENV['CI']

        @output_file_relative ||= begin
          artifacts_dir_relative = File.basename(artifacts_dir)
          File.join(artifacts_dir_relative, File.basename(output_file))
        end
      end
    end
  end
end

desc "Build #{BerkeleyLibrary::Logging.gemspec_basename} as #{BerkeleyLibrary::Logging.output_file_relative}"
task :gem do
  args = ['build', BerkeleyLibrary::Logging.gemspec_file, "--output=#{BerkeleyLibrary::Logging.output_file}"]
  Gem::GemRunner.new.run(args)
end
