module GitHelper
  class Setup
    def execute
      if config_file_exists?
        answer = highline.ask_yes_no("It looks like the #{config_file} file already exists. Do you wish to replace it? (y/n)")

        unless answer
          puts "\nExiting because you selected to not replace the #{config_file} file..."
          exit
        end
      end

      create_or_update_config_file

      # answer = highline.ask_yes_no("Do you wish to set up the Git Helper plugins? (y/n)")
      # exit unless answer

      # if plugins_exist?
      #   answer = highline.ask_yes_no("It looks like the plugins already exist. Do you wish to set up the Git Helper plugins? (y/n)")

      #   unless answer
      #     puts "\nExiting because you selected to not replace the #{config_file} file..."
      #     exit
      #   end
      # end

      # create_or_update_plugins
    end

    private def create_or_update_config_file
      contents = generate_file_contents
      puts "\nCreating or updating your #{config_file} file..."
      File.open(config_file, 'w') { |file| file.puts contents }
      puts "\nDone!"
    end

    private def config_file_exists?
      File.exists?(config_file)
    end

    private def generate_file_contents
      file_contents = ''

      if highline.ask_yes_no("\nDo you wish to set up GitHub credentials? (y/n)")
        file_contents << ":github_user:  #{ask_question('GitHub username?')}\n"
        file_contents << ":github_token: #{ask_question('GitHub personal access token? (Navigate to https://github.com/settings/tokens to create a new personal access token)')}\n"
      end

      if highline.ask_yes_no("\nDo you wish to set up GitLab credentials? (y/n)")
        file_contents << ":gitlab_user:  #{ask_question('GitLab username?')}\n"
        file_contents << ":gitlab_token: #{ask_question('GitLab personal access token? (Navigate to https://gitlab.com/-/profile/personal_access_tokens to create a new personal access token)')}\n"
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

    private def highline
      @highline ||= GitHelper::HighlineCli.new
    end

    private def config_file
      GitHelper::GitConfigReader.new.git_config_file_path
    end
  end
end
