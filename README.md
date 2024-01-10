# SimpleCov::Buildkite

[![Gem Version](https://badge.fury.io/rb/simplecov-buildkite.svg)](https://rubygems.org/gems/simplecov-buildkite) [![Build Status](https://travis-ci.org/buildkite/simplecov-buildkite.svg?branch=develop)](https://travis-ci.org/buildkite/simplecov-buildkite)

Generate [Buildkite annotations] from your [SimpleCov] coverage reports when running your build on [Buildkite].

  [Buildkite]: https://buildkite.com
  [Buildkite annotations]: https://buildkite.com/docs/agent/v3/cli-annotate
  [SimpleCov]: https://github.com/colszowka/simplecov

## Installation

Add this line to your application's Gemfile, after `simplecov`:

```ruby
gem "simplecov"
gem "simplecov-buildkite"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simplecov-buildkite

### Runtime requirements

:warning: In order to run this on Buildkite, `git` is required for performing various tasks. You'll need to make sure that this is installed and available.

## Usage

Use it alongside your favourite formatter. For example, in [Rails] with [RSpec], add it in your `spec_helper.rb` like this:

```ruby
# spec/spec_helper.rb

require "simplecov"
require "simplecov-buildkite"

SimpleCov.start "rails" do
  load_profile "buildkite"

  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Buildkite::AnnotationFormatter,
  ])
end
```

When run on Buildkite with the `"buildkite"` profile enabled, this will also output a pretty Buildkite annotation, with coverage change breakdowns for the current PR or branch and commit:

<img width="577" alt="Buildkite build showing a SimpleCov report in a Buildkite annotation" src="https://user-images.githubusercontent.com/282113/42116587-c2e9731e-7bac-11e8-9d2f-50fa7f071f09.png">

You can customize the title and annotation context using environment variables in your Pipeline. You can provide multiple coverage reports for a single build by providing distinct values for the annotation context.

```yaml
steps:
- command: bin/rails engine1:spec
  env:
    SIMPLECOV_BUILDKITE_TITLE: "Engine 1 Coverage"
    SIMPLECOV_BUILDKITE_CONTEXT: "engine-1-coverage"

- command: bin/rails engine2:spec
  env:
    SIMPLECOV_BUILDKITE_TITLE: "Engine 2 Coverage"
    SIMPLECOV_BUILDKITE_CONTEXT: "engine-2-coverage"
```

  [Rails]: https://rubyonrails.org
  [RSpec]: http://rspec.info

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/buildkite/simplecov-buildkite. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant] code of conduct.

  [Contributor Covenant]: http://contributor-covenant.org

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SimpleCov::Buildkite project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/buildkite/simplecov-buildkite/blob/master/CODE_OF_CONDUCT.md).
