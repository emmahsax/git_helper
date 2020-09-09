module GitHelper
  class EmptyCommit
    def execute
      system("git commit --allow-empty -m \"Empty commit\"")
    end
  end
end
