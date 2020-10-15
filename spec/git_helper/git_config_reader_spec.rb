require 'spec_helper'
require 'git_helper'

describe GitHelper::GitConfigReader do
  let(:github_token) { '1234ASDF1234ASDF' }
  let(:gitlab_token) { 'ASDF123ASDF1234' }
  let(:config_file) {
    {
      github_user: 'github-user-name',
      github_token: github_token,
      gitlab_user: 'gitlab-user-name',
      gitlab_token: gitlab_token
    }
  }

  subject { GitHelper::GitConfigReader.new }

  describe '#gitlab_token' do
    it 'should locate the gitlab_token' do
      expect(subject).to receive(:config_file).and_return(config_file)
      expect(subject.gitlab_token).to eq(gitlab_token)
    end

    it 'should call the config file' do
      expect(subject).to receive(:config_file).and_return(config_file)
      subject.gitlab_token
    end
  end

  describe '#github_token' do
    it 'should locate the github_token' do
      expect(subject).to receive(:config_file).and_return(config_file)
      expect(subject.github_token).to eq(github_token)
    end

    it 'should call the config file' do
      expect(subject).to receive(:config_file).and_return(config_file)
      subject.github_token
    end
  end

  describe '#config_file' do
    it 'should yaml load the file path' do
      expect(YAML).to receive(:load_file)
      subject.send(:config_file)
    end
  end

  describe '#git_config_file_path' do
    it 'should look in the current directory' do
      expect(Dir).to receive(:pwd).and_return('/Users/firstnamelastname/path/to/git_helper')
      subject.send(:git_config_file_path)
    end

    it 'should return the base path with the git config file at the end' do
      allow(Dir).to receive(:pwd).and_return('/Users/firstnamelastname/path/to/git_helper')
      expect(subject.send(:git_config_file_path)).to eq('/Users/firstnamelastname/.git_helper/config.yml')
    end
  end
end
