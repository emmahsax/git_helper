module GitHelper
  class ChangeRemote
    attr_accessor :old_owner, :new_owner

    def initialize(old_owner, new_owner)
      @old_owner = old_owner
      @new_owner = new_owner
    end

    def execute
      current_dir = Dir.pwd
      nested_dirs = Dir.entries(current_dir).select do |entry|
        entry_dir = File.join(current_dir, entry)
        File.directory?(entry_dir) && !(entry == '.' || entry == '..')
      end

      nested_dirs.each do |dir|
        process_dir(dir)
      end
    end

    private def process_dir(dir)
      Dir.chdir(dir)

      if File.exist?('.git')
        puts "Found git directory: #{dir}."
        process_git_repository
      end

      Dir.chdir(current_dir)
    end

    private def process_git_repository
      local_code.remotes.each do |remote|
        if resp.include?(old_owner)
          puts "  Git directory's remote is pointing to: '#{old_owner}'."
          process_remote(remote)
          puts '  Done.'
        else
          puts '  No need to update remote.'
        end
      end
    end

    private def process_remote(remote)
      remote_name = local_code.remote_name(remote)

      if local_code.ssh_remote?(remote)
        repo = local_code.remote_repo(remote, :ssh)
        source_name = local_code.remote_source(remote, :ssh)
        remote_url = "git@#{source_name}:#{new_owner}/#{repo}.git"
      elsif local_code.https_remote?(remote)
        repo = local_code.remote_repo(remote, :https)
        source_name = local_code.remote_source(remote, :https)
        remote_url = "https://#{source_name}/#{new_owner}/#{repo}.git"
      end

      puts "  Changing the remote URL #{remote_name} to be '#{remote_url}'."
      local_code.change_remote(remote_name, remote_url)
    end

    private def local_code
      @local_code ||= GitHelper::LocalCode.new
    end
  end
end
