# frozen_string_literal: true

module GitHelper
  class NewBranch
    def execute(new_branch_name = nil)
      branch_name = new_branch_name || GitHelper::HighlineCli.new.ask('New branch name?')
      puts "Attempting to create a new branch: #{branch_name}"
      GitHelper::LocalCode.new.new_branch(branch_name)
    end
  end
end
