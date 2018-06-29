module SimpleCov::Buildkite
  class AnnotationFormatter
    GIT_ANNOTATION_FORMAT_REGEX = /^Files (?<action>changed|added) in (?<changeset>[a-zA-Z0-9.]+)$/

    def format(result)
      git_results, general_results = filter_git_groups(ignore_empty_groups(result.groups))
                                     .values_at(:git, :general)

      message = <<~MESSAGE
        <h4>Coverage</h4>
        <dl class="flex flex-wrap m1 mxn2">
        #{git_results.to_a.reverse.map do |git_result|
          name, group = git_result

          matches = name.match GIT_ANNOTATION_FORMAT_REGEX

          title = "#{matches[:action] == 'added' ? 'New Files' : 'Files Changed'} in #{matches[:changeset].include?('...') ? 'branch' : 'commit'}"

          format_as_metric(title, group, changeset: matches[:changeset])
        end.join("\n")}
        #{format_as_metric('All Files', result)}
        </dl>
        <details>
          <summary>Coverage Breakdown</summary>
          <ul>
          #{general_results.map do |name, group|
            "<li><strong>#{name}</strong>: #{format_element(group)}</li>"
          end.join("\n")}
          </ul>
        </details>
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

        if name.match? GIT_ANNOTATION_FORMAT_REGEX
          cats[:git][name] = group
        else
          cats[:general][name] = group
        end
      end
    end

    def format_integer(integer)
      Kernel.format('%<integer>d', integer: integer).gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
    end

    def format_float(float)
      Kernel.format('%<floored_float>g', floored_float: float.floor(2))
    end

    def format_as_metric(name, element, changeset: nil)
      <<~METRIC_FORMAT
        <div class="m2">
          <dt title="#{changeset}">#{name}</dt>
          <dd>
            <span class="bold"><span class="h2 regular">#{format_float(element.covered_percent)}</span>%</span><br/>
            #{format_integer(element.covered_lines)} of #{format_integer(element.covered_lines + element.missed_lines)} lines<br/>
          </dd>
        </div>
      METRIC_FORMAT
    end

    def format_element(element)
      "#{format_float(element.covered_percent)}% coverage: #{format_integer(element.covered_lines)} of #{format_integer(element.covered_lines + element.missed_lines)} lines"
    end
  end
end
