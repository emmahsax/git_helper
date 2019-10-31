#!/usr/bin/env ruby

require_relative './octokit_client.rb'

class PullRequest
  attr_accessor :pr_title, :pr_number

  def initialize(title_or_number)
    if title_or_number.to_i > 0
      @pr_number = title_or_number.to_i
    else
      @pr_title = title_or_number
    end
  end

  def create
    begin
      pr = octokit_client.create_pull_request(repository_from_local, "master", branch_from_local, @pr_title)
      puts "Pull request successfully created: #{pr.html_url}"
    rescue Octokit::UnprocessableEntity => e
      puts 'Could not create pull request:'
      if e.message.include?('pull request already exists')
        puts '  A pull request already exists for this branch'
      elsif e.message.include?('No commits between master and')
        puts '  No commits have been pushed to GitHub'
      else
        puts e.message
      end
    end
  end

  def merge
    begin
      merge = octokit_client.merge_pull_request(repository_from_local, @pr_number, commit_message)
      puts "Pull request successfully merged: #{merge.sha}"
    rescue Octokit::UnprocessableEntity => e
      puts 'Could not merge pull request:'
      puts e.message
    rescue Octokit::NotFound => e
      puts 'Could not merge pull request:'
      puts '  Could not a locate a pull request to merge'
    rescue Octokit::MethodNotAllowed => e
      puts 'Could not merge pull_request:'
      if e.message.include?('405 - Required status check')
        puts '  A required status check has not passed'
      elsif e.message.include?('405 - Base branch was modified')
        puts '  The base branch has been modified'
      elsif e.message.include?('405 - Pull Request is not mergeable')
        puts '  The pull request is not mergeable'
      else
        puts e.message
      end
    end
  end

  private def repository_from_local
    # Get the repository by looking in the remote URLs for the full repository name
    remotes = `git remote -v`
    return remotes.scan(/\S[\s]*[\S]+.com[\S]{1}([\S]*).git/).first.first
  end

  private def branch_from_local
    # Get the current branch by looking in the list of branches for the *
    branches = `git branch`
    return branches.scan(/\*\s([\S]*)/).first.first
  end

  private def branch_from_pull_request
    octokit_client.pull_request(repository_from_local, @pr_number).head.ref
  end

  private def commit_message
    "Merge pull request ##{@pr_number} from #{github_username}/#{branch_from_pull_request}"
  end

  private def octokit_client
    @octokit_client ||= client_object.client
  end

  private def github_username
    @github_username ||= client_object.github_username
  end

  private def client_object
    @client_object ||= OctokitClient.new
  end
end

arg = ARGV[0]
option = ARGV[1]

case arg
when '-c', '--create'
  action = :create
when '-m', '--merge'
  action = :merge
when '-h', '--help', nil, ''
  puts """
Usage for working with this pull requests script:
  # Run this script from within your local repository/branch
  ruby pull_request.rb [-h|-c|-m] {option}

  -h, --help      - Displays this help information
  -c, --create    - Create a new pull request with a title (the next argument)
  -m, --merge     - Merge the pull request that corresponds to the PR number (the next argument)

Required: create or merge, option
Examples:
  ruby pull_request.rb -c 'Title of pull request'
  ruby pull_request.rb -m 101
    """
    exit(0)
end

puts "\nAttempting to #{action.to_s} pull request: #{option}", ''
pull_request = PullRequest.new(option)

case action
when :create
  pull_request.create
when :merge
  pull_request.merge
end
