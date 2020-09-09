module GitHelper
  class ChangeRemote
    def change_remote(old_owner, new_owner)
      puts "old owner: #{old_owner}"
      puts "new owner: #{new_owner}"
    #   current_dir = Dir.pwd
    #   nested_dirs = Dir.entries(current_dir).select do |entry|
    #     entry_dir = File.join(current_dir, entry)
    #     File.directory?(entry_dir) && !(entry == '.' || entry == '..')
    #   end

    #   nested_dirs.each do |dir|
    #     Dir.chdir dir
    #     if File.exist?('.git')
    #       puts "Found git directory: #{dir}."
    #       resp = `git remote -v`
    #       if resp.include?(old_owner)
    #         puts "  Git directory's remote is pointing to: '#{old_owner}'.'"
    #         repo = resp.scan(/\/([\S]*).git/).first.first.sub(old_owner, new_owner)
    #         remote_name = resp.scan(/([a-zA-z]+)/).first.first
    #         puts "  Changing the remote URL #{remote_name} to be git@github.com:#{new_owner}/#{repo}."
    #         begin
    #           `git remote set-url #{remote_name} git@github.com:#{new_owner}/#{repo}`
    #           puts "  Done."
    #         rescue Exception => e
    #           puts "  Could not complete: #{e.message}"
    #         end
    #       else
    #         puts "  No need to update this directory's remote URL."
    #       end
    #     end
    #     Dir.chdir current_dir
    #   end
    end
  end
end
