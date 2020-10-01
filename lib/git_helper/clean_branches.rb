require_relative './local_code.rb'

module GitHelper
  class CleanBranches
    def execute
      GitHelper::LocalCode.new.clean_branches
    end
  end
end
