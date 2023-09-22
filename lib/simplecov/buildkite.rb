require "simplecov"

require "simplecov/buildkite/version"
require "simplecov/buildkite/annotation_formatter"
require "simplecov/buildkite/profiles"
require "simplecov/buildkite/config"

module SimpleCov::Buildkite
  class << self
    attr_accessor :config
  end

  self.config = Config.new
end
