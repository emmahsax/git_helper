require 'highline'
require 'yaml'
require 'gitlab'
require 'octokit'
require_relative 'git_helper/version.rb'
require_relative 'git_helper/commands/change_remote.rb'
require_relative 'git_helper/commands/merge_request.rb'
require_relative 'git_helper/commands/new_branch.rb'
require_relative 'git_helper/commands/pull_request.rb'

module GitHelper; end
