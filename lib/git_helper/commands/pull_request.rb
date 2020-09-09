desc 'Create a GitHub pull request from the current branch.'
command 'pull-request' do |c|
  c.switch [:c, :create], desc: 'Create a new pull request'
  c.switch [:m, :merge], desc: 'Merge an existing pull request'

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
