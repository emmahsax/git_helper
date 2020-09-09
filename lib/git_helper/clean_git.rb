module GitHelper
  class CleanGit
    def execute
      system("git checkout $(git symbolic-ref refs/remotes/origin/HEAD | sed \"s@^refs/remotes/origin/@@\")")
      system("git pull")
      system("git fetch -p")
      system("git branch -vv | grep \"origin/.*: gone]\" | awk \"{print \$1}\" | grep -v \"*\" | xargs git branch -D")
    end
  end
end
