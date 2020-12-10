require 'spec_helper'
require 'git_helper'

describe GitHelper::LocalCode do
  let(:response) { double(:response, readline: true, to_i: 5) }
  let(:local_codeent) { double(:local_code, ask: response) }
  let(:project_name) { Faker::Lorem.word }
  let(:owner) { Faker::Name.first_name }
  let(:ssh_remote) { "origin\tgit@github.com:#{owner}/#{project_name}.git (fetch)" }
  let(:https_remote) { "origin\thttps://github.com/#{owner}/#{project_name}.git (fetch)" }

  let(:github_remotes) do
    [
      "origin\tgit@github.com:#{owner}/#{project_name}.git (fetch)",
      "origin\thttps://github.com/#{owner}/#{project_name}.git (fetch)"
    ]
  end

  let(:gitlab_remotes) do
    [
      "origin\tgit@gitlab.com:#{owner}/#{project_name}.git (fetch)",
      "origin\thttps://gitlab.com/#{owner}/#{project_name}.git (fetch)"
    ]
  end

  subject { GitHelper::LocalCode.new }

  before do
    allow(subject).to receive(:system).and_return(nil)
  end

  describe '#checkout_default' do
    it 'should make a system call' do
      expect(subject).to receive(:system)
      subject.checkout_default
    end
  end

  describe '#forget_local_commits' do
    it 'should make a system call' do
      expect(subject).to receive(:system).exactly(2).times
      subject.forget_local_commits
    end

    it 'should return nil' do
      expect(subject.forget_local_commits).to eq(nil)
    end
  end

  describe '#empty_commit' do
    it 'should make a system call' do
      expect(subject).to receive(:system)
      subject.empty_commit
    end
  end

  describe '#clean_branches' do
    it 'should make a system call' do
      expect(subject).to receive(:system).exactly(4).times
      subject.clean_branches
    end
  end

  describe '#new_branch' do
    it 'should make a system call' do
      expect(subject).to receive(:system).exactly(4).times
      subject.new_branch(Faker::Lorem.word)
    end
  end

  describe '#change_remote' do
    it 'should return a string' do
      allow(subject).to receive(:`).and_return(Faker::Lorem.word)
      expect(subject.change_remote(Faker::Lorem.word, Faker::Internet.url)).to be_a(String)
    end
  end

  describe '#remotes' do
    it 'should return an array of strings' do
      expect(subject.remotes).to be_a(Array)
      expect(subject.remotes.first).to be_a(String)
    end
  end

  describe '#remote_name' do
    it 'should be a string' do
      expect(subject.remote_name(ssh_remote)).to be_a(String)
    end
  end

  describe '#ssh_remote' do
    it 'should come out true if ssh' do
      expect(subject.ssh_remote?(ssh_remote)).to eq(true)
    end

    it 'should come out false if https' do
      expect(subject.ssh_remote?(https_remote)).to eq(false)
    end
  end

  describe '#https_remote' do
    it 'should come out false if ssh' do
      expect(subject.https_remote?(ssh_remote)).to eq(false)
    end

    it 'should come out true if https' do
      expect(subject.https_remote?(https_remote)).to eq(true)
    end
  end

  describe '#remote_project' do
    it 'should return just the plain project if ssh' do
      expect(subject.remote_project(ssh_remote)).to eq(project_name)
    end

    it 'should return just the plain project if https' do
      expect(subject.remote_project(https_remote)).to eq(project_name)
    end
  end

  describe '#remote_source' do
    it 'should return just the plain project if ssh' do
      expect(subject.remote_source(ssh_remote)).to eq('github.com')
    end

    it 'should return just the plain project if https' do
      expect(subject.remote_source(https_remote)).to eq('github.com')
    end
  end

  describe '#github_repo' do
    it 'should return true if github' do
      allow(subject).to receive(:remotes).and_return(github_remotes)
      expect(subject.github_repo?).to eq(true)
    end

    it 'should return false if gitlab' do
      allow(subject).to receive(:remotes).and_return(gitlab_remotes)
      expect(subject.github_repo?).to eq(false)
    end
  end

  describe '#gitlab_project' do
    it 'should return true if gitlab' do
      allow(subject).to receive(:remotes).and_return(gitlab_remotes)
      expect(subject.gitlab_project?).to eq(true)
    end

    it 'should return false if github' do
      allow(subject).to receive(:remotes).and_return(github_remotes)
      expect(subject.gitlab_project?).to eq(false)
    end
  end

  describe '#project_name' do
    it 'should return a string' do
      expect(subject.project_name).to be_a(String)
    end

    it 'should equal this project name' do
      allow_any_instance_of(String).to receive(:scan).and_return([["#{owner}/#{project_name}"]])
      expect(subject.project_name).to eq("#{owner}/#{project_name}")
    end
  end

  describe '#branch' do
    it 'should return a string' do
      expect(subject.branch).to be_a(String)
    end
  end

  describe '#default_branch' do
    it 'should return a string' do
      expect(subject.default_branch).to be_a(String)
    end
  end

  describe '#template_options' do
    let(:template_identifiers) do
      {
        template_directory: '.github',
        nested_directory_name: 'PULL_REQUEST_TEMPLATE',
        non_nested_file_name: 'pull_request_template'
      }
    end

    it 'should return an array' do
      expect(subject.template_options(template_identifiers)).to be_a(Array)
    end

    it 'should call Dir.glob and File.join' do
      expect(Dir).to receive(:glob).and_return(['.github/pull_request_template.md']).at_least(:once)
      expect(File).to receive(:join).at_least(:once)
      subject.template_options(template_identifiers)
    end
  end

  describe '#read_template' do
    it 'should call File.open' do
      expect(File).to receive(:open).and_return(double(read: true))
      subject.read_template('.gitignore')
    end
  end

  describe '#generate_title' do
    it 'should return a title based on the branch' do
      prefix = Faker::Lorem.word
      word1 = Faker::Lorem.word
      word2 = Faker::Lorem.word
      description = [word1, word2].join('-')
      branch = "#{prefix}-123-#{description}"
      expect(subject.generate_title(branch)).to eq("#{prefix.upcase}-123 #{[word1.capitalize, word2].join(' ')}")
    end

    it 'should return a title based on the branch' do
      prefix = Faker::Lorem.word
      word1 = Faker::Lorem.word
      word2 = Faker::Lorem.word
      description = [word1, word2].join('_')
      branch = "#{prefix}_123_#{description}"
      expect(subject.generate_title(branch)).to eq("#{prefix.upcase}-123 #{[word1.capitalize, word2].join(' ')}")
    end

    it 'should return a title based on the branch' do
      prefix = Faker::Lorem.word
      word1 = Faker::Lorem.word
      word2 = Faker::Lorem.word
      description = [word1, word2].join('_')
      branch = "#{prefix}-123_#{description}"
      expect(subject.generate_title(branch)).to eq("#{prefix.upcase}-123 #{[word1.capitalize, word2].join(' ')}")
    end

    it 'should return a title based on the branch' do
      word1 = Faker::Lorem.word
      word2 = Faker::Lorem.word
      branch = [word1, word2].join('_')
      expect(subject.generate_title(branch)).to eq([word1.capitalize, word2].join(' '))
    end

    it 'should return a title based on the branch' do
      word1 = Faker::Lorem.word
      word2 = Faker::Lorem.word
      branch = [word1, word2].join('-')
      expect(subject.generate_title(branch)).to eq([word1.capitalize, word2].join(' '))
    end

    it 'should return a title based on the branch' do
      branch = Faker::Lorem.word
      expect(subject.generate_title(branch)).to eq(branch.capitalize)
    end

    it 'should return a title based on the branch' do
      word1 = Faker::Lorem.word
      word2 = Faker::Lorem.word
      word3 = Faker::Lorem.word
      branch = [word1, word2, word3].join('_')
      expect(subject.generate_title(branch)).to eq([word1.capitalize, word2, word3].join(' '))
    end

    it 'should return a title based on the branch' do
      word1 = Faker::Lorem.word
      word2 = Faker::Lorem.word
      word3 = Faker::Lorem.word
      branch = [word1, word2, word3].join('-')
      expect(subject.generate_title(branch)).to eq([word1.capitalize, word2, word3].join(' '))
    end
  end
end
