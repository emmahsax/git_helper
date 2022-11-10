# frozen_string_literal: true

require File.expand_path('lib/git_helper/version.rb', __dir__)

Gem::Specification.new do |gem|
  gem.authors               = ['Emma Sax']
  gem.description           = 'A set of GitHub and GitLab workflow scripts to provide a smoother development ' \
                              'process for your git projects.'
  gem.executables           = Dir['bin/*'].map { |f| File.basename(f) }

  gem.files = Dir['lib/git_helper/*.rb'] + Dir['lib/*.rb'] + Dir['bin/*']
  gem.files += Dir['[A-Z]*'] + Dir['test/**/*']
  gem.files.reject! { |fn| fn.include? '.gem' }

  gem.homepage              = 'https://github.com/emmahsax/git_helper'
  gem.license               = 'BSD-3-Clause'
  gem.metadata              = { 'rubygems_mfa_required' => 'true' }
  gem.name                  = 'git_helper'
  gem.require_paths         = ['lib']
  gem.required_ruby_version = '>= 2.5'
  gem.summary               = 'A set of GitHub and GitLab workflow scripts'
  gem.version               = GitHelper::VERSION

  gem.add_dependency 'gli', '~> 2.13'
  gem.add_dependency 'highline_wrapper', '~> 1.1'

  gem.add_development_dependency 'bundler', '~> 2.2'
  gem.add_development_dependency 'faker', '~> 3.0'
  gem.add_development_dependency 'guard-rspec', '~> 4.3'
  gem.add_development_dependency 'pry', '~> 0.13'
  gem.add_development_dependency 'rspec', '~> 3.9'
  gem.add_development_dependency 'rubocop', '~> 1.10'
end
