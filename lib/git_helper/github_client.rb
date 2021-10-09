# frozen_string_literal: true

module GitHelper
  class GitHubClient
    def repository(repo_name)
      run(repo_name.split('/').first, nil, "/repos/#{repo_name}")
    end

    def pull_request(repo_name, pull_request_id)
      run(repo_name.split('/').first, nil, "/repos/#{repo_name}/pulls/#{pull_request_id}")
    end

    def create_pull_request(repo_name, options)
      opts_as_string = format_options(options)
      run(
        repo_name.split('/').first,
        'POST',
        "/repos/#{repo_name}/pulls",
        opts_as_string
      )
    end

    def merge_pull_request(repo_name, pull_request_id, options)
      opts_as_string = format_options(options)
      run(
        repo_name.split('/').first,
        'PUT',
        "/repos/#{repo_name}/pulls/#{pull_request_id}/merge",
        opts_as_string
      )
    end

    private def format_options(options)
      opts_as_string = ''.dup
      options.each do |key, value|
        next if value == ''

        opts_as_string << "#{key.to_json}:#{value.to_json.gsub("'", "'\\\\''")},"
      end
      opts_as_string = opts_as_string.reverse.sub(',', '').reverse
      opts_as_string.empty? ? '' : "{#{opts_as_string}}"
    end

    # rubocop:disable Layout/LineLength
    private def run(username, request_type, curl_url, options = '')
      OpenStruct.new(
        JSON.parse(
          if request_type
            `curl -s -u #{username}:#{github_token} -H "Accept: application/vnd.github.v3+json" -X #{request_type} -d '#{options}' "#{github_endpoint}#{curl_url}"`
          else
            `curl -s -u #{username}:#{github_token} -H "Accept: application/vnd.github.v3+json" "#{github_endpoint}#{curl_url}"`
          end
        )
      )
    end
    # rubocop:enable Layout/LineLength

    private def github_token
      git_config_reader.github_token
    end

    private def git_config_reader
      @git_config_reader ||= GitHelper::GitConfigReader.new
    end

    private def github_endpoint
      'https://api.github.com'
    end
  end
end
