require File.expand_path('../lib/git_helper/version.rb', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Emma Sax']
  gem.email         = ['emma.sax4@gmail.com']
  gem.description   = %q{A set of GitHub and GitLab workflow scripts.}
  gem.summary       = %q{A set of GitHub and GitLab workflow scripts to provide a smoother development process for your git projects.}
  gem.homepage      = 'https://github.com/emmasax4/git_helper'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files = Dir['lib/git_helper/*.rb'] + Dir['lib/git_helper/scripts/*.rb'] + Dir['lib/git_helper/commands/*.rb'] + Dir['lib/*.rb'] + Dir['bin/*']
  gem.files += Dir['[A-Z]*'] + Dir['test/**/*']
  gem.files.reject! { |fn| fn.include? '.gem' }
  # gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = 'git_helper'
  gem.license       = 'MIT'
  gem.require_paths = ['lib']
  gem.version       = GitHelper::VERSION

  gem.add_dependency 'gitlab', '~> 4.16'
  gem.add_dependency 'gli', '~> 2.13'
  gem.add_dependency 'highline', '~> 2.0'
  gem.add_dependency 'octokit', '~> 4.18'

  gem.add_development_dependency 'bundler', '~> 2.1'
  gem.add_development_dependency 'guard', '~> 2.6'
  gem.add_development_dependency 'guard-rspec', '~> 4.3'
  gem.add_development_dependency 'rake', '~> 10.1'
  gem.add_development_dependency 'rspec', '~> 2.99'
end
