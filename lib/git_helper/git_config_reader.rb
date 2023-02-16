# frozen_string_literal: true

module GitHelper
  class GitConfigReader
    def gitlab_token
      config_file[:gitlab_token]
    end

    def gitlab_user
      config_file[:gitlab_user]
    end

    def github_token
      config_file[:github_token]
    end

    def github_user
      config_file[:github_user]
    end

    def git_config_file_path
      "#{Dir.home}/.git_helper/config.yml"
    end

    private def config_file
      YAML.load_file(git_config_file_path)
    end
  end
end
