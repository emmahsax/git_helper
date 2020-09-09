arg :old_owner, name: 'old_owner'
arg :new_owner, name: 'new_owner'
desc "Update a repository's remote URLs from an old GitHub owner to a new owner"
command 'change-remote' do |c|
  c.action do |global_options, options, args|
    require_relative '../scripts/change_remote.rb'
    GitHelper::ChangeRemote.new.change_remote(args[0], args[1])
  end
end
