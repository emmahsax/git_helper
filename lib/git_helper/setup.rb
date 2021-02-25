module GitHelper
  class Setup
    def execute
      if config_file_exists?
        answer = highline.ask_yes_no("It looks like the #{config_file} file already exists. Do you wish to replace it? (y/n)")
        puts
      else
        answer = true
      end

      create_or_update_config_file if answer

      answer = highline.ask_yes_no(
        "Do you wish to set up the Git Helper plugins? (y/n) (This process will " \
        "attempt to use your GitHub personal access token to authenticate)"
      )

      if answer
        create_or_update_plugin_files
        puts "\nNow add this line to your ~/.bash_profile:\n  export PATH=/path/to/computer/home/.git_helper/plugins:$PATH"
        puts "\nDone!"
      end
    end

    private def create_or_update_config_file
      contents = generate_file_contents
      puts "\nCreating or updating your #{config_file} file..."
      File.open(config_file, 'w') { |file| file.puts contents }
      puts "\nDone!\n\n"
    end

    private def config_file_exists?
      File.exists?(config_file)
    end

    private def generate_file_contents
      file_contents = ''

      if highline.ask_yes_no("Do you wish to set up GitHub credentials? (y/n)")
        file_contents << ":github_user:  #{ask_question('GitHub username?')}\n"
        file_contents << ":github_token: " \
          "#{ask_question('GitHub personal access token? (Navigate to https://github.com/settings/tokens ' \
          'to create a new personal access token)')}\n"
      end

      if highline.ask_yes_no("\nDo you wish to set up GitLab credentials? (y/n)")
        file_contents << ":gitlab_user:  #{ask_question('GitLab username?')}\n"
        file_contents << ":gitlab_token: " \
          "#{ask_question('GitLab personal access token? (Navigate to https://gitlab.com/-/profile/personal_access_tokens ' \
          'to create a new personal access token)')}\n"
      end

      file_contents.strip
    end

    private def ask_question(prompt)
      answer = highline.ask("\n#{prompt}")

      if answer.empty?
        puts "\nThis question is required."
        ask_question(prompt)
      else
        answer
      end
    end

    private def create_or_update_plugin_files
      plugins_dir = "#{Dir.pwd.scan(/\A\/[\w]*\/[\w]*\//).first}/.git_helper/plugins"
      plugins_url = 'https://api.github.com/repos/emmahsax/git_helper/contents/plugins'
      header = 'Accept: application/vnd.github.v3.raw'
      token = git_config_reader.github_token
      user = git_config_reader.github_user

      Dir.mkdir(plugins_dir) unless File.exists?(plugins_dir)

      all_plugins = JSON.parse(`curl -s -u #{user}:#{token} -H "#{header}" -L "#{plugins_url}"`)

      all_plugins.each do |plugin|
        plugin_content = `curl -s -u #{user}:#{token} -H "#{header}" -L "#{plugins_url}/#{plugin['name']}"`
        File.open("#{plugins_dir}/#{plugin['name']}", 'w') { |file| file.puts plugin_content }
      end
    end

    private def config_file
      git_config_reader.git_config_file_path
    end

    private def git_config_reader
      @git_config_reader ||= GitHelper::GitConfigReader.new
    end

    private def highline
      @highline ||= GitHelper::HighlineCli.new
    end
  end
end
