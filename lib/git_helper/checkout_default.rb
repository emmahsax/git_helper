module GitHelper
  class CheckoutDefault
    def execute
      system("git checkout $(git symbolic-ref refs/remotes/origin/HEAD | sed \"s@^refs/remotes/origin/@@\")")
    end
  end
end
