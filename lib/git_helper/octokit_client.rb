# frozen_string_literal: true

module GitHelper
  class OctokitClient
    def client
      Octokit::Client.new(access_token: git_config_reader.github_token)
    end

    private def git_config_reader
      @git_config_reader ||= GitHelper::GitConfigReader.new
    end
  end
end
