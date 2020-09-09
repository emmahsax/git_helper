module GitHelper
  class ChangeRemote
    def execute(old_owner, new_owner)
      current_dir = Dir.pwd
      nested_dirs = Dir.entries(current_dir).select do |entry|
        entry_dir = File.join(current_dir, entry)
        File.directory?(entry_dir) && !(entry == '.' || entry == '..')
      end

      nested_dirs.each do |dir|
        Dir.chdir dir
        if File.exist?('.git')
          puts "Found git directory: #{dir}."
          remotes = `git remote -v`.split("\n")
          remotes.each do |remote|
            if resp.include?(old_owner)
              puts "  Git directory's remote is pointing to: '#{old_owner}'."
              swap_ssh(old_owner, new_owner, remote) if remote.scan(/(git@)/).any?
              swap_https(old_owner, new_owner, remote) if remote.scan(/(https:\/\/)/).any?
            else
              puts "  No need to update remote."
            end
          end
        end
        Dir.chdir current_dir
      end
    end

    private def swap_https(old_owner, new_owner, remote)
      repo = remote.scan(/https:\/\/[\S]+\/([\S]*).git/).first.first
      remote_name = remote.scan(/([a-zA-z]+)/).first.first
      source_name = scan(/https:\/\/([a-zA-z.]+)\//).first.first
      puts "  Changing the remote URL #{remote_name} to be 'https://#{source_name}/#{new_owner}/#{repo}.git'."
      begin
        `git remote set-url #{remote_name} https://#{source_name}:#{new_owner}/#{repo}.git`
        puts "  Done."
      rescue Exception => e
        puts "  Could not complete: #{e.message}"
      end
    end

    private def swap_ssh(old_owner, new_owner, remote)
      repo = remote.scan(/\/([\S]*).git/).first.first
      remote_name = remote.scan(/([a-zA-z]+)/).first.first
      source_name = remote.scan(/git@([a-zA-z.]+):/).first.first
      puts "  Changing the remote URL #{remote_name} to be 'git@#{source_name}:#{new_owner}/#{repo}.git'."
      begin
        `git remote set-url #{remote_name} git@#{source_name}:#{new_owner}/#{repo}.git`
        puts "  Done."
      rescue Exception => e
        puts "  Could not complete: #{e.message}"
      end
    end
  end
end
