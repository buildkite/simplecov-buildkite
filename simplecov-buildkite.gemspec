Gem::Specification.new do |spec|
  spec.name = "simplecov-buildkite"
  spec.version = File.read("#{__dir__}/lib/simplecov/buildkite/version.rb")[/VERSION = "(.*)"/, 1]
  spec.authors = ["Jessica Stokes", "Samuel Cochran"]
  spec.email = ["hello@jessicastokes.net", "sj26@sj26.com"]

  spec.summary = "Generate SimpleCov reports for your parallel Buildkite builds"
  spec.homepage = "https://github.com/ticky/simplecov-buildkite"
  spec.license = "MIT"

  spec.files = Dir["*.md", "LICENSE", "lib/**/*"]

  spec.metadata = {
    "changelog_uri" => "#{spec.homepage}/blob/master/CHANGELOG.md",
  }

  spec.add_dependency "simplecov", "~> 0.16"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
