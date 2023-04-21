# frozen_string_literal: true

module GitHelper
  class Setup
    def execute
      execute_config_file
      execute_plugins
    end

    # rubocop:disable Style/ConditionalAssignment
    private def execute_config_file
      if config_file_exists?
        answer = highline.ask_yes_no(
          "It looks like the #{config_file} file already exists. Do you wish to replace it? (y/n)",
          { required: true }
        )
      else
        answer = true
      end

      create_or_update_config_file if answer
    end
    # rubocop:enable Style/ConditionalAssignment

    private def execute_plugins
      answer = highline.ask_yes_no(
        'Do you wish to set up the Git Helper plugins? (y/n)',
        { required: true }
      )

      return unless answer

      create_or_update_plugin_files
      puts "\nNow add this line to your ~/.zshrc:\n  " \
           'export PATH="$HOME/.git_helper/plugins:$PATH"'
      puts "\nDone!"
    end

    private def create_or_update_config_file
      contents = generate_file_contents
      puts "Creating or updating your #{config_file} file..."
      FileUtils.mkdir_p("#{Dir.home}/.git_helper")
      File.open(config_file, 'w') { |file| file.puts contents }
      puts "\nDone!\n\n"
    end

    private def config_file_exists?
      File.exist?(config_file)
    end

    # rubocop:disable Metrics/MethodLength
    private def generate_file_contents
      file_contents = ''.dup

      if highline.ask_yes_no('Do you wish to set up GitHub credentials? (y/n)', { required: true })
        file_contents << ":github_user:  #{ask_question('GitHub username?')}\n"
        file_contents << ':github_token: ' \
          "#{ask_question(
            'GitHub personal access token? (Navigate to https://github.com/settings/tokens ' \
            'to create a new personal access token)',
            secret: true
          )}\n"
      end

      if highline.ask_yes_no('Do you wish to set up GitLab credentials? (y/n)', { required: true })
        file_contents << ":gitlab_user:  #{ask_question('GitLab username?')}\n"
        file_contents << ':gitlab_token: ' \
          "#{ask_question(
            'GitLab personal access token? (Navigate to https://gitlab.com/-/profile/personal_access_tokens ' \
            'to create a new personal access token)',
            secret: true
          )}\n"
      end

      file_contents.strip
    end
    # rubocop:enable Metrics/MethodLength

    private def ask_question(prompt, secret: false)
      highline.ask(prompt, { required: true, secret: secret })
    end

    private def create_or_update_plugin_files
      plugins_dir = "#{Dir.home}/.git_helper/plugins"
      plugins_url = 'https://api.github.com/repos/emmahsax/git_helper/contents/plugins'
      header = 'Accept: application/vnd.github.v3.raw'

      FileUtils.mkdir_p(plugins_dir)

      all_plugins = JSON.parse(`curl -s -H "#{header}" -L "#{plugins_url}"`)

      all_plugins.each do |plugin|
        plugin_content = `curl -s -H "#{header}" -L "#{plugins_url}/#{plugin['name']}"`
        File.open("#{plugins_dir}/#{plugin['name']}", 'w', 0755) { |file| file.puts plugin_content }
      end
    end

    private def config_file
      git_config_reader.git_config_file_path
    end

    private def git_config_reader
      @git_config_reader ||= GitHelper::GitConfigReader.new
    end

    private def highline
      @highline ||= HighlineWrapper.new
    end
  end
end
