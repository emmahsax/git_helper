require 'gitlab'

module GitHelper
  class GitLabClient
    def client
      Gitlab.client(endpoint: gitlab_endpoint, private_token: git_config_reader.gitlab_token)
    end

    private def git_config_reader
      @git_config_reader ||= GitConfigReader.new
    end

    private def gitlab_endpoint
      'https://gitlab.com/api/v4'
    end
  end
end
