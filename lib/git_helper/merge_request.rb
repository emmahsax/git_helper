# frozen_string_literal: true

module GitHelper
  class GitLabMergeRequest
    attr_accessor :local_project, :local_branch, :local_code, :cli, :base_branch, :new_mr_title

    def initialize(options)
      @local_project = options[:local_project]
      @local_branch = options[:local_branch]
      @local_code = options[:local_code]
      @cli = options[:cli]
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def create(options)
      @base_branch = options[:base_branch]
      @new_mr_title = options[:new_title]

      options = {
        source_branch: local_branch,
        target_branch: base_branch,
        squash: squash_merge_request,
        remove_source_branch: remove_source_branch,
        description: new_mr_body
      }

      puts "Creating merge request: #{new_mr_title}"
      mr = gitlab_client.create_merge_request(local_project, new_mr_title, options)

      if mr.diff_refs.base_sha == mr.diff_refs.head_sha
        puts "Merge request was created, but no commits have been pushed to GitLab: #{mr.web_url}"
      else
        puts "Merge request successfully created: #{mr.web_url}"
      end
    rescue Gitlab::Error::Conflict
      puts 'Could not create merge request:'
      puts '  A merge request already exists for this branch'
    rescue StandardError => e
      puts 'Could not create merge request:'
      puts e.message
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def merge
      mr_id
      options = {
        should_remove_source_branch: existing_mr.should_remove_source_branch || existing_mr.force_remove_source_branch,
        squash: existing_mr.squash,
        squash_commit_message: existing_mr.title
      }

      puts "Merging merge request: #{mr_id}"
      merge = gitlab_client.accept_merge_request(local_project, mr_id, options)

      if merge.merge_commit_sha.nil?
        options[:squash] = true
        merge = gitlab_client.accept_merge_request(local_project, mr_id, options)
      end

      if merge.merge_commit_sha.nil?
        puts 'Could not merge merge request:'
        puts "  #{merge.merge_error}"
      else
        puts "Merge request successfully merged: #{merge.merge_commit_sha}"
      end
    rescue Gitlab::Error::MethodNotAllowed
      puts 'Could not merge merge request:'
      puts '  The merge request is not mergeable'
    rescue Gitlab::Error::NotFound
      puts 'Could not merge merge request:'
      puts "  Could not a locate a merge request to merge with ID #{mr_id}"
    rescue StandardError => e
      puts 'Could not merge merge request:'
      puts e.message
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    private def new_mr_body
      @new_mr_body ||= template_name_to_apply ? local_code.read_template(template_name_to_apply) : ''
    end

    private def template_name_to_apply
      return @template_name_to_apply if @template_name_to_apply

      @template_name_to_apply = nil

      determine_template unless mr_template_options.empty?

      @template_name_to_apply
    end

    # rubocop:disable Metrics/MethodLength
    private def determine_template
      if mr_template_options.count == 1
        apply_single_template = cli.ask_yes_no(
          "Apply the merge request template from #{mr_template_options.first}? (y/n)"
        )
        @template_name_to_apply = mr_template_options.first if apply_single_template
      else
        response = cli.ask_options(
          'Which merge request template should be applied?', mr_template_options << 'None'
        )
        @template_name_to_apply = response unless response == 'None'
      end
    end
    # rubocop:enable Metrics/MethodLength

    private def mr_template_options
      @mr_template_options ||= local_code.template_options(
        {
          template_directory: '.gitlab',
          nested_directory_name: 'merge_request_templates',
          non_nested_file_name: 'merge_request_template'
        }
      )
    end

    private def mr_id
      @mr_id ||= cli.ask('Merge Request ID?')
    end

    private def squash_merge_request
      @squash_merge_request ||= cli.ask_yes_no('Squash merge request? (y/n)')
    end

    private def remove_source_branch
      @remove_source_branch ||=
        existing_project.remove_source_branch_after_merge || cli.ask_yes_no(
          'Remove source branch after merging? (y/n)'
        )
    end

    private def existing_project
      @existing_project ||= gitlab_client.project(local_project)
    end

    private def existing_mr
      @existing_mr ||= gitlab_client.merge_request(local_project, mr_id)
    end

    private def gitlab_client
      @gitlab_client ||= GitHelper::GitLabClient.new.client
    end
  end
end
