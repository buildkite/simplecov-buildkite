module SimpleCov::Buildkite
  class AnnotationFormatter
    def format(result)
      git_results, general_results = filter_git_groups(result.groups)
                                     .values_at(:git, :general)

      message = <<~MESSAGE
        <details>
          <summary>#{format_element(result)}</summary>
          <ul>
          #{ignore_empty_groups(general_results).map do |name, group|
            "<li><strong>#{name}</strong>: #{format_element(group)}</li>"
          end.join("\n")}
          </ul>
        </details>
        <ul>
        #{git_results.map do |name, group|
          "<li><strong>#{name}</strong>: #{format_element(group)}</li>"
        end.join("\n")}
        </ul>
      MESSAGE

      if ENV['BUILDKITE']
        system 'buildkite-agent',
               'annotate',
               '--context', 'simplecov',
               '--style', 'info',
               message
      else
        puts message
      end
    end

    private

    def ignore_empty_groups(groups)
      groups.select do |_name, group|
        (group.covered_lines + group.missed_lines).positive?
      end
    end

    def filter_git_groups(groups)
      groups.each_with_object(git: {}, general: {}) do |unzipped_group, cats|
        name, group = unzipped_group

        if name.match?(/^Files (?:added|changed) in [a-zA-Z0-9]+/)
          cats[:git][name] = group
        else
          cats[:general][name] = group
        end
      end
    end

    def format_element(element)
      "#{element.covered_percent.round(2)}% coverage: #{format_integer(element.covered_lines)} of #{format_integer(element.covered_lines + element.missed_lines)} lines"
    end

    def format_integer(integer)
      integer.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
    end
  end
end
