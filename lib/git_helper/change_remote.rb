require_relative './highline_cli.rb'
require_relative './local_code.rb'

module GitHelper
  class ChangeRemote
    attr_accessor :old_owner, :new_owner

    def initialize(old_owner, new_owner)
      @old_owner = old_owner
      @new_owner = new_owner
    end

    def execute
      original_dir = Dir.pwd
      nested_dirs = Dir.entries(original_dir).select do |entry|
        entry_dir = File.join(original_dir, entry)
        File.directory?(entry_dir) && !(entry == '.' || entry == '..')
      end

      nested_dirs.each do |nested_dir|
        process_dir(nested_dir, original_dir)
      end
    end

    private def process_dir(current_dir, original_dir)
      Dir.chdir(current_dir)

      if File.exist?('.git')
        process_git_repository if cli.process_directory_remotes?(current_dir)
      end

      Dir.chdir(original_dir)
    end

    private def process_git_repository
      local_code.remotes.each do |remote|
        if remote.include?(old_owner)
          process_remote(remote)
        else
          puts "  Found remote is not pointing to #{old_owner}."
        end
      end
      puts "\n"
    end

    private def process_remote(remote)
      remote_name = local_code.remote_name(remote)

      if local_code.ssh_remote?(remote)
        repo = local_code.remote_repo(remote)
        source_name = local_code.remote_source(remote)
        remote_url = "git@#{source_name}:#{new_owner}/#{repo}.git"
      elsif local_code.https_remote?(remote)
        repo = local_code.remote_repo(remote)
        source_name = local_code.remote_source(remote)
        remote_url = "https://#{source_name}/#{new_owner}/#{repo}.git"
      end

      puts "  Changing the remote URL #{remote_name} to be '#{remote_url}'."
      local_code.change_remote(remote_name, remote_url)
    end

    private def local_code
      @local_code ||= GitHelper::LocalCode.new
    end

    private def cli
      @cli ||= GitHelper::HighlineCli.new
    end
  end
end
