require 'yaml'
require 'gitlab'

class GitLabClient
  def client
    Gitlab.client(endpoint: gitlab_endpoint, private_token: gitlab_token)
  end

  private def gitlab_token
    config_file[:gitlab_token]
  end

  private def config_file
    YAML.load_file(git_config_file_path)
  end

  private def git_config_file_path
    Dir.pwd.scan(/\A\/[\w]*\/[\w]*\//).first << git_config_file
  end

  private def git_config_file
    '.git_config.yml'
  end

  private def gitlab_endpoint
    'https://gitlab.com/api/v4'
  end
end
