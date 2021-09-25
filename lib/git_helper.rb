# frozen_string_literal: true

require 'yaml'
require 'json'
require 'highline_wrapper'

files = "#{File.expand_path(File.join(File.dirname(File.absolute_path(__FILE__)), 'git_helper'))}/**/*.rb"

Dir[files].each do |file|
  require_relative file
end

module GitHelper; end
