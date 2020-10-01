module GitHelper
  class LocalCode
    def name
      # Get the repo/project name by looking in the remote URLs for the full name
      remotes = `git remote -v`
      return remotes.scan(/\S[\s]*[\S]+.com[\S]{1}([\S]*).git/).first.first
    end

    def branch
      # Get the current branch by looking in the list of branches for the *
      branches = `git branch`
      return branches.scan(/\*\s([\S]*)/).first.first
    end

    def default_branch(project_name, external_client)
      if external_client.instance_of?(GitHelper::OctokitClient) # GitHub repository
        return external_client.repository(local_repo).default_branch
      elsif external_client.instance_of?(GitHelper::GitLabClient) # GitLab project
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

        return default_branch.name
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
      return nested_templates.concat(non_nested_templates)
    end

    def read_template(file_name)
      File.open(file_name).read
    end

    def generate_title(local_branch)
      branch_arr = local_branch.split(local_branch.include?('_') ? '_' : '-')

      return if branch_arr.empty?

      if branch_arr.length == 1
        return branch_arr.first.capitalize
      end

      if branch_arr[0].scan(/([\w]+)/).empty? || branch_arr[1].scan(/([\d]+)/).empty?
        return branch_arr[0..-1].join(' ').capitalize
      else
        issue = branch_arr[0].upcase

        if issue.include?('-')
          description = branch_arr[1..-1].join(' ')
        else
          issue = "#{issue}-#{branch_arr[1]}"
          description = branch_arr[2..-1].join(' ')
        end

        return "#{issue} #{description.capitalize}"
      end
    end
  end
end
