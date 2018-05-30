require "spec_helper"

RSpec.describe SimpleCov::Buildkite::AnnotationFormatter do
  let(:result) { SimpleCov::Result.from_hash("RSpec" => {"coverage" => {"a.rb" => [1, 0], "b.rb" => [0, 1]}, "timestamp" => 1527643747}) }

  subject(:formatter) { SimpleCov::Buildkite::AnnotationFormatter.new }

  before { allow(SimpleCov).to receive(:groups).and_return("a" => "a", "b" => "b") }

  context "outside of buildkite" do
    around { |example| stubbing_env("BUILDKITE", nil) { example.call } }

    it "outputs a nicely formatter annotation" do
      expect { formatter.format(result) }.to output(<<~MESSAGE).to_stdout
        <details>
        <summary>**100.0% coverage: 0.0 of 0.0 lines**</summary>

         * **a**: 100.0% coverage: 0.0 of 0.0 lines
         * **b**: 100.0% coverage: 0.0 of 0.0 lines
        </details>
      MESSAGE
    end
  end

  context "inside buildkite" do
    around { |example| stubbing_env("BUILDKITE", "true") { example.call } }

    it "creates a nicely formatted annotation" do
      expect(formatter).to receive(:system).with("buildkite-agent", "annotate", "--context", "simplecov", "--style", "info", <<~MESSAGE)
        <details>
        <summary>**100.0% coverage: 0.0 of 0.0 lines**</summary>

         * **a**: 100.0% coverage: 0.0 of 0.0 lines
         * **b**: 100.0% coverage: 0.0 of 0.0 lines
        </details>
      MESSAGE

      formatter.format(result)
    end
  end

  def stubbing_env(name, value)
    begin
      original = ENV[name]

      if value.nil?
        ENV.delete(name)
      else
        ENV[name] = value
      end

      yield
    ensure
      if original.nil?
        ENV.delete(name)
      else
        ENV[name] = original
      end
    end
  end
end
