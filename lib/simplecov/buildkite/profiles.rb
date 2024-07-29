# frozen_string_literal: true

module SimpleCov::Buildkite::Profiles
  def self.run(*args)
    IO.popen(args, &:read).tap do
      $?.success? or fail("Command exited with status #{$?.exitstatus}: #{args.join(" ")}")
    end.chomp
  end

  def self.git(*args)
    run 'git',
        *args
  end

  def self.git_diff_names(*args, diff_filter: '')
    git('diff',
        '--name-only',
        "--diff-filter=#{diff_filter}",
        *args).split "\n"
  end

  def self.git_short_commit(commit)
    git 'rev-parse',
        '--short',
        commit
  end

  def self.git_merge_base(*refs)
    git 'merge-base',
        *refs
  end

  def self.git_fetch(branch)
    git 'fetch', 'origin', branch
  end

  SimpleCov.profiles.define 'buildkite' do
    STDERR.puts 'SimpleCov::Buildkite profile initialising...'
    fail('Not running on Buildkite') unless ENV['BUILDKITE'] == 'true'

    branch_name = ENV['BUILDKITE_BRANCH']

    STDERR.puts "branch_name=#{branch_name}"

    base_branch_name = ENV['BUILDKITE_PULL_REQUEST_BASE_BRANCH']
    if base_branch_name.nil? || base_branch_name.empty?
      base_branch_name = ENV['BUILDKITE_PIPELINE_DEFAULT_BRANCH']
    end

    STDERR.puts "base_branch_name=#{base_branch_name}"
    git_fetch("#{base_branch_name}:#{base_branch_name}")

    current_commit = ENV['BUILDKITE_COMMIT']

    STDERR.puts "current_commit=#{current_commit}"

    current_commit_short = git_short_commit(current_commit)

    STDERR.puts "current_commit_short=#{current_commit_short}"

    changed_files_in_commit = git_diff_names(current_commit,
                                             diff_filter: 'd')

    STDERR.puts "changed_files_in_commit.count=#{changed_files_in_commit.count}"

    add_group "Files changed in #{current_commit_short}" do |tested_file|
      changed_files_in_commit.detect do |changed_file|
        tested_file.filename.end_with?(changed_file)
      end
    end

    added_files_in_commit = git_diff_names(current_commit,
                                           diff_filter: 'A')

    STDERR.puts "added_files_in_commit.count=#{added_files_in_commit.count}"

    add_group "Files added in #{current_commit_short}" do |tested_file|
      added_files_in_commit.detect do |added_file|
        tested_file.filename.end_with?(added_file)
      end
    end

    # Compare with the base branch if it's not this branch
    if base_branch_name && base_branch_name != branch_name
      merge_base = git_merge_base(current_commit,
                                  base_branch_name)

      merge_base_short = git_short_commit(merge_base)

      STDERR.puts "merge_base=#{merge_base}"
      STDERR.puts "merge_base_short=#{merge_base_short}"

      changed_files_in_branch = git_diff_names(merge_base,
                                               current_commit,
                                               diff_filter: 'd')

      STDERR.puts "changed_files_in_branch.count=#{changed_files_in_branch.count}"

      add_group "Files changed in #{merge_base_short}...#{current_commit_short}" do |tested_file|
        changed_files_in_branch.detect do |changed_file|
          tested_file.filename.end_with?(changed_file)
        end
      end

      added_files_in_branch = git_diff_names(merge_base,
                                             current_commit,
                                             diff_filter: 'A')

      STDERR.puts "added_files_in_branch.count=#{added_files_in_branch.count}"

      add_group "Files added in #{merge_base_short}...#{current_commit_short}" do |tested_file|
        added_files_in_branch.detect do |added_file|
          tested_file.filename.end_with?(added_file)
        end
      end
    end
  rescue RuntimeError => error
    STDERR.puts error
  end
end
