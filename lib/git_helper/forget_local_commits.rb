module GitHelper
  class ForgetLocalCommits
    def execute
      GitHelper::LocalCode.new.forget_local_commits
    end
  end
end
