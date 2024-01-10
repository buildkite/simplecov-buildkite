require "shellwords"

module SimpleCov::Buildkite
  class AnnotationFormatter
    GIT_ANNOTATION_FORMAT_REGEX = /^Files (?<action>changed|added) in (?<changeset>[a-zA-Z0-9.]+)$/

    def format(result)
      git_results, general_results = filter_git_groups(ignore_empty_groups(result.groups))
                                     .values_at(:git, :general)

      message = <<~MESSAGE
        #### #{annotation_title}

        <dl class="flex flex-wrap m1 mxn2">
      MESSAGE

      git_results.to_a.reverse.each do |git_result|
        name, group = git_result

        matches = name.match GIT_ANNOTATION_FORMAT_REGEX

        type = if matches[:action] == 'added'
                 'New files'
               else
                 'Files changed'
               end

        changeset = if matches[:changeset].include?('...')
                      'branch'
                    else
                      'commit'
                    end

        message += format_as_metric "#{type} in #{changeset}",
                                    group,
                                    changeset: matches[:changeset]
      end

      message += format_as_metric 'All files', result

      message += <<~MESSAGE
        </dl>
      MESSAGE

      if general_results.any?
        message += <<~MESSAGE
          <details><summary>Coverage breakdown</summary>

            #{general_results.map do |name, group|
              "- **#{name}**: #{format_group(group)}"
            end.join("\n")}

          </details>
        MESSAGE
      end

      if ENV['BUILDKITE']
        system 'buildkite-agent',
               'annotate',
               '--context', annotation_context,
               '--style', 'info',
               message
      else
        puts message
      end
    end

    private

    def annotation_title
      ENV.fetch("SIMPLECOV_BUILDKITE_TITLE", "Coverage")
    end

    def annotation_context
      Shellwords.shellescape(ENV.fetch("SIMPLECOV_BUILDKITE_CONTEXT", "simplecov"))
    end

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
      metric = <<~METRIC_HEADER
        <div class="m2"><dt#{changeset.nil? ? '' : " title=\"#{changeset}\""}>#{name}</dt><dd>
      METRIC_HEADER

      metric += <<~METRIC_VALUE

        **<span class="h2 regular">#{format_float(element.covered_percent)}</span>%**
        #{format_line_count(element)}

      METRIC_VALUE

      metric += <<~METRIC_FOOTER
        </dd></div>
      METRIC_FOOTER
    end

    def format_group(element)
      "#{format_float(element.covered_percent)}% coverage: #{format_line_count(element)}"
    end

    def format_line_count(element)
      "#{format_integer(element.covered_lines)} of #{format_integer(element.covered_lines + element.missed_lines)} lines"
    end
  end
end
