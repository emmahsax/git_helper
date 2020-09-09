arg :new_branch_name, optional: true
desc 'Create a new branch for features, bug fixes, or experimentation.'
command 'new-branch' do |c|
  c.action do |global_options, options, args|
    require_relative '../scripts/new_branch.rb'
    GitHelper::NewBranch.new.create_new_branch(args[0])
  end
end
