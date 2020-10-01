module GitHelper
  class LocalCode
    def checkout_default
      system("git checkout $(git symbolic-ref refs/remotes/origin/HEAD | sed \"s@^refs/remotes/origin/@@\")")
    end

    def empty_commit
      system("git commit --allow-empty -m \"Empty commit\"")
    end

    def clean_branches
      system("git checkout $(git symbolic-ref refs/remotes/origin/HEAD | sed \"s@^refs/remotes/origin/@@\")")
      system("git pull")
      system("git fetch -p")
      system("git branch -vv | grep \"origin/.*: gone]\" | awk '{print \$1}' | grep -v \"*\" | xargs git branch -D")
    end

    def new_branch(branch_name)
      system("git pull")
      system("git branch --no-track #{branch_name}")
      system("git checkout #{branch_name}")
      system("git push --set-upstream origin #{branch_name}")
    end

    def change_remote(remote_name, remote_url)
      `git remote set-url #{remote_name} #{remote_url}`
    end

    def remotes
      `git remote -v`.split("\n")
    end

    def remote_name(remote)
      remote.scan(/([a-zA-z]+)/).first.first
    end

    def ssh_remote?(remote)
      remote.scan(/(git@)/).any?
    end

    def https_remote?(remote)
      remote.scan(/(https:\/\/)/).any?
    end

    def remote_repo(remote, remote_type)
      if remote_type == :https
        remote.scan(/https:\/\/[\S]+\/([\S]*).git/).first.first
      elsif remote_type == :ssh
        remote.scan(/\/([\S]*).git/).first.first
      end
    end

    def remote_source(remote, remote_type)
      if remote_type == :https
        remote.scan(/https:\/\/([a-zA-z.]+)\//).first.first
      elsif remote_type == :ssh
        remote.scan(/git@([a-zA-z.]+):/).first.first
      end
    end

    def name
      # Get the repo/project name by looking in the remote URLs for the full name
      `git remote -v`.scan(/\S[\s]*[\S]+.com[\S]{1}([\S]*).git/).first.first
    end

    def branch
      # Get the current branch by looking in the list of branches for the *
      `git branch`.scan(/\*\s([\S]*)/).first.first
    end

    def default_branch(project_name, external_client, client_type)
      if client_type == :octokit # GitHub repository
        external_client.repository(project_name).default_branch
      elsif client_type == :gitlab # GitLab project
        page_number = 1
        counter = 1
        branches = []

        while counter > 0
          break if default_branch = branches.select { |branch| branch.default }.first
          page_branches = external_client.branches(project_name, page: page_number, per_page: 100)
          branches = page_branches
          counter = page_branches.count
          page_number += 1
        end

        default_branch.name
      end
    end

    def template_options(template_identifiers)
      nested_templates = Dir.glob(
        File.join("**/#{template_identifiers[:nested_directory_name]}", "*.md"),
        File::FNM_DOTMATCH | File::FNM_CASEFOLD
      )
      non_nested_templates = Dir.glob(
        File.join("**", "#{template_identifiers[:non_nested_file_name]}.md"),
        File::FNM_DOTMATCH | File::FNM_CASEFOLD
      )
      nested_templates.concat(non_nested_templates).uniq
    end

    def read_template(file_name)
      File.open(file_name).read
    end

    def generate_title(local_branch)
      branch_arr = local_branch.split(local_branch.include?('_') ? '_' : '-')

      return if branch_arr.empty?

      if branch_arr.length == 1
        branch_arr.first.capitalize
      elsif branch_arr[0].scan(/([\w]+)/).any? && branch_arr[1].scan(/([\d]+)/).any? # branch includes jira_123 at beginning
        issue = "#{branch_arr[0].upcase}-#{branch_arr[1]}"
        description = branch_arr[2..-1].join(' ')
        "#{issue} #{description.capitalize}"
      elsif branch_arr[0].scan(/([\w]+-[\d]+)/).any? # branch includes string jira-123 at beginning
        issue = branch_arr[0].upcase
        description = branch_arr[1..-1].join(' ')
        "#{issue} #{description.capitalize}"
      else # plain words
        branch_arr[0..-1].join(' ').capitalize
      end
    end
  end
end
