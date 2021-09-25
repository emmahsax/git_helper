# frozen_string_literal: true

module GitHelper
  class GitLabClient
    def project(project_name)
      run('GET', "/projects/#{url_encode(project_name)}")
    end

    def merge_request(project_name, merge_request_id)
      run('GET', "/projects/#{url_encode(project_name)}/merge_requests/#{merge_request_id}")
    end

    def create_merge_request(project_name, options)
      opts_as_string = format_options(options)
      run('POST', "/projects/#{url_encode(project_name)}/merge_requests#{opts_as_string}")
    end

    def accept_merge_request(project_name, merge_request_id, options)
      opts_as_string = format_options(options)
      run(
        'PUT',
        "/projects/#{url_encode(project_name)}/merge_requests/#{merge_request_id}/merge#{opts_as_string}"
      )
    end

    private def format_options(options)
      opts_as_string = ''.dup
      options.each do |key, value|
        next if value == ''

        opts_as_string << "#{key}=#{value}&"
      end
      opts_as_string = opts_as_string.reverse.sub('&', '').reverse
      opts_as_string.empty? ? '' : "?#{opts_as_string}"
    end

    private def run(request_type, curl_url)
      OpenStruct.new(
        JSON.parse(
          `curl -s -X #{request_type} -H "PRIVATE-TOKEN: #{gitlab_token}" "#{gitlab_endpoint}#{curl_url}"`
        )
      )
    end

    private def url_encode(string)
      string.b.gsub(/[^a-zA-Z0-9_\-.~]/n) { |m| format('%%%<val>02X', val: m.unpack1('C')) }
    end

    private def gitlab_token
      git_config_reader.gitlab_token
    end

    private def git_config_reader
      @git_config_reader ||= GitConfigReader.new
    end

    private def gitlab_endpoint
      'https://gitlab.com/api/v4'
    end
  end
end
