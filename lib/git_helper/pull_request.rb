# frozen_string_literal: true

module GitHelper
  class GitHubPullRequest
    attr_accessor :local_repo, :local_branch, :local_code, :highline, :base_branch, :new_pr_title

    def initialize(options)
      @local_repo = options[:local_project]
      @local_branch = options[:local_branch]
      @local_code = options[:local_code]
      @highline = options[:highline]
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def create(options)
      @base_branch = options[:base_branch]
      @new_pr_title = options[:new_title]

      new_pr_body

      puts "Creating pull request: #{new_pr_title}"
      pr = octokit_client.create_pull_request(
        local_repo,
        base_branch,
        local_branch,
        new_pr_title,
        new_pr_body
      )
      puts "Pull request successfully created: #{pr.html_url}"
    rescue Octokit::UnprocessableEntity => e
      puts 'Could not create pull request:'
      if e.message.include?('pull request already exists')
        puts '  A pull request already exists for this branch'
      elsif e.message.include?('No commits between')
        puts '  No commits have been pushed to GitHub'
      else
        puts e.message
      end
    rescue StandardError => e
      puts 'Could not create pull request:'
      puts e.message
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def merge
      pr_id
      merge_method

      puts "Merging pull request: #{pr_id}"
      merge = octokit_client.merge_pull_request(
        local_repo,
        pr_id,
        existing_pr.title,
        { merge_method: merge_method }
      )
      puts "Pull request successfully merged: #{merge.sha}"
    rescue Octokit::NotFound
      puts 'Could not merge pull request:'
      puts "  Could not a locate a pull request to merge with ID #{pr_id}"
    rescue Octokit::MethodNotAllowed => e
      puts 'Could not merge pull request:'
      if e.message.include?('405 - Required status check')
        puts '  A required status check has not passed'
      elsif e.message.include?('405 - Base branch was modified')
        puts '  The base branch has been modified'
      elsif e.message.include?('405 - Pull Request is not mergeable')
        puts '  The pull request is not mergeable'
      elsif e.message.include?('405 - Rebase merges are not allowed on this repository')
        puts '  Rebase merges are not allowed on this repository'
      elsif e.message.include?('405 - Merge commits are not allowed on this repository')
        puts '  Merge commits are not allowed on this repository'
      elsif e.message.include?('405 - Squash commits are not allowed on this repository')
        puts '  Squash merges are not allowed on this repository'
      else
        puts e.message
      end
    rescue StandardError => e
      puts 'Could not merge pull request:'
      puts e.message
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    private def new_pr_body
      @new_pr_body ||= template_name_to_apply ? local_code.read_template(template_name_to_apply) : ''
    end

    private def template_name_to_apply
      return @template_name_to_apply if @template_name_to_apply

      @template_name_to_apply = nil

      determine_template unless pr_template_options.empty?

      @template_name_to_apply
    end

    # rubocop:disable Metrics/MethodLength
    private def determine_template
      if pr_template_options.count == 1
        apply_single_template = highline.ask_yes_no(
          "Apply the pull request template from #{pr_template_options.first}? (y/n)"
        )
        @template_name_to_apply = pr_template_options.first if apply_single_template
      else
        response = highline.ask_options(
          'Which pull request template should be applied?', pr_template_options << 'None'
        )
        @template_name_to_apply = response unless response == 'None'
      end
    end
    # rubocop:enable Metrics/MethodLength

    private def pr_template_options
      @pr_template_options ||= local_code.template_options(
        {
          template_directory: '.github',
          nested_directory_name: 'PULL_REQUEST_TEMPLATE',
          non_nested_file_name: 'pull_request_template'
        }
      )
    end

    private def pr_id
      @pr_id ||= highline.ask('Pull Request ID?')
    end

    private def merge_method
      @merge_method ||=
        if merge_options.length == 1
          merge_options.first
        else
          highline.ask_options('Merge method?', merge_options)
        end
    end

    private def merge_options
      return @merge_options if @merge_options

      merge_options = []
      merge_options << 'merge' if existing_project.allow_merge_commit
      merge_options << 'squash' if existing_project.allow_squash_merge
      merge_options << 'rebase' if existing_project.allow_rebase_merge
      @merge_options = merge_options
    end

    private def existing_project
      @existing_project ||= octokit_client.repository(local_repo)
    end

    private def existing_pr
      @existing_pr ||= octokit_client.pull_request(local_repo, pr_id)
    end

    private def octokit_client
      @octokit_client ||= GitHelper::OctokitClient.new.client
    end
  end
end
