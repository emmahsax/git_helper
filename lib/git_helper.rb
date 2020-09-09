require 'highline'
require 'yaml'
require 'gitlab'
require 'octokit'
require_relative 'git_helper/version'
require_relative 'git_helper/commands/change_remote'
require_relative 'git_helper/commands/merge_request'
require_relative 'git_helper/commands/new_branch'
require_relative 'git_helper/commands/pull_request'

module GitHelper; end
