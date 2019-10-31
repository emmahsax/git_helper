class NewBranch
  attr_accessor :branch_name

  def initialize(branch_name)
    @branch_name = branch_name
  end

  def create_new_branch
    if @branch_name
      system("git branch --no-track #{@branch_name}")
      system("git checkout #{@branch_name}")
      system("git branch --set-upstream-to=origin #{@branch_name}")
      system("git pull")
      system("git push")
    else
      puts 'No branch name was provided.'
    end
  end
end

NewBranch.new(ARGV[0]).create_new_branch
