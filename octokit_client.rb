require 'yaml'
require 'octokit'

class OctokitClient
  # You'll want Octokit version >= 4.18.0, but in your local directory
  def client
    Octokit::Client.new(access_token: github_token)
  end

  private def github_token
    config_file[:github_token]
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
end
