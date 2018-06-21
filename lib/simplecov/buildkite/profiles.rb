# frozen_string_literal: true

module SimpleCov::Buildkite::Profiles
  def self.run(*args)
    IO.popen(args, &:read).tap do
      $?.success? or fail("Command exited with status #{$?.exitstatus}: #{args.join(" ")}")
    end
  end

  SimpleCov.profiles.define 'buildkite' do
    STDERR.puts 'SimpleCov::Buildkite profile initialising...'
    fail("Not running on Buildkite") unless ENV['BUILDKITE'] == 'true'

    base_branch_name = (
      ENV['BUILDKITE_PULL_REQUEST_BASE_BRANCH'] ||
      ENV['BUILDKITE_PIPELINE_DEFAULT_BRANCH']
    )

    STDERR.puts "base_branch_name=#{base_branch_name}"

    if base_branch_name.nil?
      changed_files = run('git',
                          'diff',
                          '--name-only',
                          'HEAD',
                          'HEAD^').split "\n"

      STDERR.puts "changed_files=#{changed_files}"

      add_group "Changed in #{ENV['BUILDKITE_COMMIT'] || 'this commit'}" do |tested_file|
        changed_files.detect do |changed_file|
          tested_file.filename.ends_with?(changed_file)
        end
      end
    else
      run('git',
          'merge-base',
          '--is-ancestor',
          base_branch_name,
          'HEAD')

      merge_base = run('git',
                       'merge-base',
                       'HEAD',
                       base_branch_name)

      changed_files = run('git',
                          'diff',
                          '--name-only',
                          'HEAD',
                          merge_base).split "\n"
      return unless $CHILD_STATUS == 0

      add_group "Changed from #{base_branch_name}" do |tested_file|
        changed_files.detect do |changed_file|
          tested_file.filename.ends_with?(changed_file)
        end
      end
    end
  rescue RuntimeError => error
    STDERR.puts error
  end
end
