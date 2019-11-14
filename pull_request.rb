#!/usr/bin/env ruby

require_relative './octokit_client.rb'
require_relative './highline_cli.rb'

class PullRequest
  def create
    begin
      title = accept_auto_generated_title? ? auto_generated_title : cli.ask('Title?')
      puts "Creating pull request: #{title}"
      pr = octokit_client.create_pull_request(local_repo, "master", local_branch, pr_data)
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
      pr_id = cli.ask('Pull Request ID?')
      puts "Merging pull request: #{pr_id}"
      merge = octokit_client.merge_pull_request(local_repo, pr_data)
      puts "Pull request successfully merged: #{merge.sha}"
    rescue Octokit::UnprocessableEntity => e
      puts 'Could not merge pull request:'
      puts e.message
    rescue Octokit::NotFound => e
      puts 'Could not merge pull request:'
      puts "  Could not a locate a pull request to merge with ID #{pr_id}"
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

  private def local_repo
    # Get the repository by looking in the remote URLs for the full repository name
    remotes = `git remote -v`
    return remotes.scan(/\S[\s]*[\S]+.com[\S]{1}([\S]*).git/).first.first
  end

  private def local_branch
    # Get the current branch by looking in the list of branches for the *
    branches = `git branch`
    return branches.scan(/\*\s([\S]*)/).first.first
  end

  private def auto_generated_title
    @auto_generated_title ||= local_branch.split('_')[0..-1].join(' ').capitalize
  end

  private def accept_auto_generated_title?
    answer = cli.ask("Accept the auto-generated title: '#{auto_generated_title}' (y/n)")
    !!(answer =~ /^y/i)
  end

  private def octokit_client
    @octokit_client ||= OctokitClient.new.client
  end

  private def cli
    @cli ||= HighlineCli.new
  end
end

arg = ARGV[0]

case arg
when '-c', '--create'
  action = :create
when '-m', '--merge'
  action = :merge
when '-h', '--help', nil, ''
  puts """
Usage for working with this pull requests script:
  # Run this script from within your local repository/branch
  ./pull_request.rb [-h|-c|-m]

  -h, --help      - Displays this help information
  -c, --create    - Create a new pull request with a title (the next argument)
  -m, --merge     - Merge the pull request that corresponds to the PR number (the next argument)

Required: create or merge
Examples:
  ./pull_request.rb -c
  ./pull_request.rb -m
    """
    exit(0)
end

pull_request = PullRequest.new

case action
when :create
  pull_request.create
when :merge
  pull_request.merge
end
