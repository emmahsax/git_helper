require_relative './highline_cli.rb'

module GitHelper
  class NewBranch
    def execute(new_branch_name = nil)
      branch_name = new_branch_name || cli.new_branch_name
      puts "Attempting to create a new branch: #{branch_name}"
      local_code.new_branch(branch_name)
    end

    private def cli
      @cli ||= GitHelper::HighlineCli.new
    end

    private def local_code
      @local_code ||= GitHelper::LocalCode.new
    end
  end
end
