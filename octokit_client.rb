require 'yaml'
require 'octokit'

class OctokitClient
  GITHUB_CONFIG_FILE = ".automation/config.yml"

  attr_accessor :user

  def initialize(user=nil)
    @user = user
  end

  def client
    Octokit::Client.new(access_token: github_token)
  end

  def github_username
    @user ? config_file[@user][:github_user] : config_file[:github_user]
  end

  private def github_token
    @user ? config_file[@user][:github_token] : config_file[:github_token]
  end

  private def config_file
    YAML.load_file(github_config_file_path)
  end

  private def github_config_file_path
    Dir.pwd.scan(/\A\/[\w]*\/[\w]*\//).first << GITHUB_CONFIG_FILE
  end
end
