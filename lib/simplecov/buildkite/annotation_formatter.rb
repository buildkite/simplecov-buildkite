module SimpleCov::Buildkite
  class AnnotationFormatter
    def format(result)
      message = <<~MESSAGE
        <details>
        <summary>#{format_element(result)}</summary>
        <ul>
        #{result.groups.map do |name, group|
          "<li><strong>#{name}</strong>: #{format_element(group)}</li>"
        end.join("\n")}
        </ul>
        </details>
      MESSAGE

      if ENV["BUILDKITE"]
        system "buildkite-agent", "annotate", "--context", "simplecov", "--style", "info", message
      elsif ENV["SIMPLECOV_BUILDKITE_TOFILE"]
        IO.write("coverage/buildkite-annotations.html", message)
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
