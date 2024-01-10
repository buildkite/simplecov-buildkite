# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
[Unreleased]: https://github.com/buildkite/simplecov-buildkite/compare/v0.3.0...HEAD

- Nothing yet.

## [0.3.0] - 2024-01-10
[0.3.0]: https://github.com/buildkite/simplecov-buildkite/compare/v0.2.0...v0.3.0

### Added
- Set the annotation title with the `SIMPLECOV_BUILDKITE_TITLE` env var
  ([#21](https://github.com/buildkite/simplecov-buildkite/pull/21))
- Set the annotation context with the `SIMPLECOV_BUILDKITE_CONTEXT` env var. This is useful for
  adding multiple annotations to a single build
  ([#18](https://github.com/buildkite/simplecov-buildkite/pull/18),
  [#21](https://github.com/buildkite/simplecov-buildkite/pull/21))

## [0.2.0] - 2020-09-08
[0.2.0]: https://github.com/buildkite/simplecov-buildkite/compare/v0.1.1...v0.2.0

### Changed
- git integration: SimpleCov groups are automatically generated based on branch
  and commit metadata.
  ([#2](https://github.com/buildkite/simplecov-buildkite/pull/2),
  [#8](https://github.com/buildkite/simplecov-buildkite/pull/8))
- Headers are now in sentence case
  ([#9](https://github.com/buildkite/simplecov-buildkite/pull/9))
- Update specs for SimpleCov 0.19.0
  ([#12](https://github.com/buildkite/simplecov-buildkite/pull/12))

## [0.1.1] - 2018-05-30
[0.1.1]: https://github.com/buildkite/simplecov-buildkite/compare/v0.1.0...v0.1.1

### Changed
- Output is now enclosed in a `<details>` for a brief summary with expandable
  group stats

## [0.1.0] - 2018-05-30
[0.1.0]: https://github.com/buildkite/simplecov-buildkite/commits/v0.1.0

### Added
- New gem, simplecov-buildkite. 🎉
- Buildkite annotation formatter to consolidate reports from multiple simplecov
  runs into a Buildkite annotation.
