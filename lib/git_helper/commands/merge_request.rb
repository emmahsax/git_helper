desc "Create a GitLab merge request from the current branch."
command 'merge-request' do |c|
  c.switch [:c, :create], desc: 'Create a new pull request'
  c.switch [:m, :merge], desc: 'Merge an existing pull request'

  c.action do |global_options, options, args|
    require_relative '../scripts/merge_request.rb'
    options = global_options.merge(options)

    if options[:create]
      GitHelper::GitLabMergeRequest.new.create
    elsif options[:merge]
      GitHelper::GitLabMergeRequest.new.merge
    end
  end
end
