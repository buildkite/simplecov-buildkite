# frozen_string_literal: true

require 'English'

module SimpleCov::Buildkite::Profiles
  SimpleCov.profiles.define 'buildkite' do
    return unless ENV['BUILDKITE'] == 'true'

    base_branch_name = (
      ENV['BUILDKITE_PULL_REQUEST_BASE_BRANCH'] ||
      ENV['BUILDKITE_PIPELINE_DEFAULT_BRANCH']
    )

    if base_branch_name.nil?
      changed_files = `git diff --name-only HEAD HEAD^`.split "\n"
      return unless $CHILD_STATUS == 0

      add_group "Changed in #{ENV['BUILDKITE_COMMIT'] || 'this commit'}" do |tested_file|
        changed_files.detect do |changed_file|
          tested_file.filename.ends_with?(changed_file)
        end
      end
    else
      `git merge-base --is-ancestor #{base_branch_name} HEAD`
      return unless $CHILD_STATUS == 0

      merge_base = `git merge-base HEAD #{base_branch_name}`
      return unless $CHILD_STATUS == 0

      changed_files = `git diff --name-only HEAD #{merge_base}`.split "\n"
      return unless $CHILD_STATUS == 0

      add_group "Changed from #{base_branch_name}" do |tested_file|
        changed_files.detect do |changed_file|
          tested_file.filename.ends_with?(changed_file)
        end
      end
    end
  end
end
