require_relative './highline_cli.rb'

module GitHelper
  class NewBranch
    def create_new_branch(new_branch_name = nil)
      branch_name = new_branch_name || cli.ask('New branch name?')
      puts "Attempting to create a new branch: #{branch_name}"
      system("git pull")
      system("git branch --no-track #{branch_name}")
      system("git checkout #{branch_name}")
      system("git push --set-upstream origin #{branch_name}")
    end

    private def cli
      @cli ||= GitHelper::HighlineCli.new
    end
  end
end
