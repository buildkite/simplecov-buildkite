module SimpleCov::Buildkite
  class AnnotationFormatter
    def format(result)
      message = <<~MESSAGE
        <details>
        <summary>**#{format_element(result)}**</summary>

        #{result.groups.map do |name, group|
          " * **#{name}**: #{format_element(group)}"
        end.join("\n")}
        </details>
      MESSAGE

      if ENV["BUILDKITE"]
        system "buildkite-agent", "annotate", "--context", "simplecov", "--style", "info", message
      else
        puts message
      end
    end

    private

    def format_element(element)
      "#{element.covered_percent.round(2)}% coverage: #{format_integer(element.covered_lines)} of #{format_integer(element.covered_lines + element.missed_lines)} lines"
    end

    def format_integer(integer)
      integer.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
    end
  end
end
