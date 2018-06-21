# frozen_string_literal: true

module SimpleCov::Buildkite::Profiles
  def self.run(*args)
    IO.popen(args, &:read).tap do
      $?.success? or fail("Command exited with status #{$?.exitstatus}: #{args.join(" ")}")
    end.chomp
  end

  SimpleCov.profiles.define 'buildkite' do
    STDERR.puts 'SimpleCov::Buildkite profile initialising...'
    fail("Not running on Buildkite") unless ENV['BUILDKITE'] == 'true'

    base_branch_name = (
      ENV['BUILDKITE_PULL_REQUEST_BASE_BRANCH'] ||
      ENV['BUILDKITE_PIPELINE_DEFAULT_BRANCH']
    )

    STDERR.puts "base_branch_name=#{base_branch_name}"

    current_commit = ENV['BUILDKITE_COMMIT']

    STDERR.puts "current_commit=#{current_commit}"

    current_commit_short = run('git',
                               'rev-parse',
                               '--short',
                               current_commit)

    STDERR.puts "current_commit_short=#{current_commit_short}"

    changed_files_in_commit = run('git',
                                  'diff',
                                  '--name-only',
                                  '--diff-filter=d',
                                  current_commit,
                                  "#{current_commit}^").split "\n"

    STDERR.puts "changed_files_in_commit=#{changed_files_in_commit}"

    add_group "Files changed in #{current_commit_short}" do |tested_file|
      changed_files_in_commit.detect do |changed_file|
        tested_file.filename.ends_with?(changed_file)
      end
    end

    if base_branch_name
      merge_base = run('git',
                       'merge-base',
                       current_commit,
                       base_branch_name)

      merge_base_short = run('git',
                             'rev-parse',
                             '--short',
                             merge_base)

      STDERR.puts "merge_base=#{merge_base}"
      STDERR.puts "merge_base_short=#{merge_base_short}"

      changed_files_in_branch = run('git',
                                    'diff',
                                    '--name-only',
                                    '--diff-filter=d',
                                    current_commit,
                                    merge_base).split "\n"

      STDERR.puts "changed_files_in_branch.count=#{changed_files_in_branch.count}"

      add_group "Files changed in #{merge_base_short}...#{current_commit_short}" do |tested_file|
        changed_files_in_branch.detect do |changed_file|
          tested_file.filename.ends_with?(changed_file)
        end
      end
    end
  rescue RuntimeError => error
    STDERR.puts error
  end
end
