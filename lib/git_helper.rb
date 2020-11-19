require 'yaml'
require 'gitlab'
require 'highline'
require 'octokit'

Dir[File.expand_path(File.join(File.dirname(File.absolute_path(__FILE__)), 'git_helper')) + '/**/*.rb'].each do |file|
  require_relative file
end

module GitHelper; end
