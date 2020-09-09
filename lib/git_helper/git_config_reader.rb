require 'yaml'

module GitHelper
  class GitConfigReader
    def gitlab_token
      config_file[:gitlab_token]
    end

    def github_token
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
end
