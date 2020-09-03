#!/usr/bin/env ruby

require_relative './highline_cli.rb'

class NewBranch
  def create_new_branch
    branch_name = cli.ask('New branch name?')
    puts "Attempting to create a new branch: #{branch_name}"
    system("git pull")
    system("git branch --no-track #{branch_name}")
    system("git checkout #{branch_name}")
    system("git push --set-upstream origin #{branch_name}")
  end

  private def cli
    @cli ||= HighlineCli.new
  end
end

NewBranch.new.create_new_branch
