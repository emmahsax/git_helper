require 'yaml'
require 'octokit'

class OctokitClient
  def client
    Octokit::Client.new(access_token: github_token)
  end

  private def github_token
    config_file[github_user][:github_token]
  end

  private def github_user
    # Always user the GitHub user that the individual repo uses to commit with
    @github_user ||= `git config user.name`.strip
  end

  private def config_file
    YAML.load_file(github_config_file_path)
  end

  private def github_config_file_path
    Dir.pwd.scan(/\A\/[\w]*\/[\w]*\//).first << github_config_file
  end

  private def github_config_file
    '.scripts_git_users.yml'
  end
end
