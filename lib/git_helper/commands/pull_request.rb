desc "Create a GitHub pull request from the current branch."

command 'pr' do |c|
  c.desc 'Create a new pull request'
  c.switch [:c, :create], :arg_name => 'create'

  c.desc 'Merge an existing pull request'
  c.switch [:m, :merge], :arg_name => 'merge'

  c.action do |global_options, options, args|
    require_relative '../scripts/pull_request.rb'
    options = global_options.merge(options)

    if options[:create]
      GitHelper::GitHubPullRequest.new.create
    elsif options[:merge]
      GitHelper::GitHubPullRequest.new.merge
    end
  end
end
