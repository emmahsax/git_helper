require_relative './local_code.rb'

module GitHelper
  class EmptyCommit
    def execute
      GitHelper::LocalCode.new.empty_commit
    end
  end
end
