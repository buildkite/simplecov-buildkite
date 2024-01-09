require 'spec_helper'

RSpec.describe SimpleCov::Buildkite::AnnotationFormatter do
  let(:result) do
    # As of SimpleCov 0.19.0, `SimpleCov::Result.from_hash` now returns an array:
    # https://github.com/simplecov-ruby/simplecov/commit/9ed35debcd6e5b4a22e99a655c9b40be0d7da142
    # This is an API intended for internal use, though, and plugins are passed
    # merged result objects, so we work around this API difference here.
    SimpleCov::Result.from_hash({"RSpec" => {"coverage" => {"a.rb" => [1, 0], "b.rb" => [0, 1]}, "timestamp" => 1527643747}}).first
  end

  subject(:formatter) { SimpleCov::Buildkite::AnnotationFormatter.new }

  before do
    allow(SimpleCov).to receive(:groups).and_return("a" => "a", "b" => "b")
  end

  before do
    @original_env = ENV.to_h
  end

  after do
    ENV.replace(@original_env)
  end

  describe "output" do
    context 'outside of buildkite' do
      before do
        ENV.delete("BUILDKITE")
      end

      it 'emits a nicely formatted annotation to STDOUT' do
        expect { formatter.format(result) }.to output(<<~MESSAGE).to_stdout
          #### Coverage

          <dl class="flex flex-wrap m1 mxn2">
          <div class="m2"><dt>All files</dt><dd>

          **<span class="h2 regular">100</span>%**
          0 of 0 lines

          </dd></div>
          </dl>
        MESSAGE
      end
    end

    context 'inside Buildkite' do
      before do
        ENV["BUILDKITE"] = "true"
      end

      it 'submits a nicely formatted annotation to the Agent' do
        expect(formatter).to receive(:system).with('buildkite-agent', 'annotate', '--context', 'simplecov', '--style', 'info', <<~MESSAGE)
          #### Coverage

          <dl class="flex flex-wrap m1 mxn2">
          <div class="m2"><dt>All files</dt><dd>

          **<span class="h2 regular">100</span>%**
          0 of 0 lines

          </dd></div>
          </dl>
        MESSAGE

        formatter.format(result)
      end
    end
  end
end
