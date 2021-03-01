# frozen_string_literal: true

module GitHelper
  class CleanBranches
    def execute
      GitHelper::LocalCode.new.clean_branches
    end
  end
end
