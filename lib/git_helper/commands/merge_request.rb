desc "Create a GitLab merge request from the current branch."

command 'mr' do |c|
  c.desc 'Create a new merge request'
  c.switch [:c, :create], :arg_name => 'create'

  c.desc 'Merge an existing merge request'
  c.switch [:m, :merge], :arg_name => 'merge'

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
