require 'spec_helper'
require 'git_helper'

describe GitHelper::GitConfigReader do
  let(:github_token) { Faker::Internet.password(max_length: 10) }
  let(:gitlab_token) { Faker::Internet.password(max_length: 10) }

  let(:config_file) {
    {
      github_user: Faker::Internet.username,
      github_token: github_token,
      gitlab_user: Faker::Internet.username,
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
      expect(Dir).to receive(:pwd).and_return("/Users/#{Faker::Name.first_name}/#{Faker::Lorem.word}")
      subject.send(:git_config_file_path)
    end

    it 'should return the base path with the git config file at the end' do
      user = Faker::Name.first_name
      allow(Dir).to receive(:pwd).and_return("/Users/#{user}/#{Faker::Lorem.word}")
      expect(subject.send(:git_config_file_path)).to eq("/Users/#{user}/.git_helper/config.yml")
    end
  end
end
