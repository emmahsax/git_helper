#!/usr/bin/env ruby

class NewBranch
  attr_accessor :branch_name

  def initialize(branch_name)
    @branch_name = branch_name
  end

  def create_new_branch
    system("git branch --no-track #{@branch_name}")
    system("git checkout #{@branch_name}")
    system("git branch --set-upstream-to=origin #{@branch_name}")
    system("git pull")
    system("git push")
  end
end

arg = ARGV[0]

if arg == '-h' || arg == '--help' || arg.nil? || arg == ''
  puts """
Usage for creating new branches:
  # Run this script from within your local repository/branch
  ./new_branch.rb {branch_name}

  -h, --help      - Displays this help information

Required: branch_name
Examples:
  ./new_branch.rb my_new_feature_branch
    """
    exit(0)
end

puts "\nAttempting to create a new branch: #{arg}", ''
NewBranch.new(arg).create_new_branch
