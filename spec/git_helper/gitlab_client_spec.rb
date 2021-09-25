# frozen_string_literal: true

require 'spec_helper'
require 'git_helper'

describe GitHelper::GitLabClient do
  let(:git_config_reader) { double(:git_config_reader, gitlab_token: :token) }

  subject { GitHelper::GitLabClient.new }

  before do
    allow(GitHelper::GitConfigReader).to receive(:new).and_return(git_config_reader)
  end

  describe '#project' do
    it 'should call to run a query' do
      expect(subject).to receive(:run)
      subject.project(Faker::Lorem.word)
    end

    it "should return the run command's answer" do
      expect(subject).to receive(:run).and_return(:command_complete)
      expect(subject.project(Faker::Lorem.word)).to eq(:command_complete)
    end
  end

  describe '#merge_request' do
    it 'should call to run a query' do
      expect(subject).to receive(:run)
      subject.merge_request(Faker::Lorem.word, Faker::Number.number)
    end

    it "should return the run command's answer" do
      expect(subject).to receive(:run).and_return(:command_complete)
      expect(subject.merge_request(Faker::Lorem.word, Faker::Number.number)).to eq(:command_complete)
    end
  end

  describe '#create_merge_request' do
    it 'should call to run a query' do
      expect(subject).to receive(:run)
      subject.create_merge_request(Faker::Lorem.word, {})
    end

    it 'should generate a string list of options' do
      expect(subject).to receive(:format_options).with({})
      subject.create_merge_request(Faker::Lorem.word, {})
    end

    it "should return the run command's answer" do
      expect(subject).to receive(:run).and_return(:command_complete)
      expect(subject.create_merge_request(Faker::Lorem.word, {})).to eq(:command_complete)
    end
  end

  describe '#accept_merge_request' do
    it 'should call to run a query' do
      expect(subject).to receive(:run)
      subject.accept_merge_request(Faker::Lorem.word, Faker::Number.number, {})
    end

    it 'should generate a string list of options' do
      expect(subject).to receive(:format_options).with({})
      subject.accept_merge_request(Faker::Lorem.word, Faker::Number.number, {})
    end

    it "should return the run command's answer" do
      expect(subject).to receive(:run).and_return(:command_complete)
      expect(subject.accept_merge_request(Faker::Lorem.word, Faker::Number.number, {})).to eq(:command_complete)
    end
  end

  describe '#format_options' do
    it 'will make a list of hash options into a URL string' do
      options = {
        key1: 'value1',
        key2: true,
        key3: '',
        key4: false,
        key5: 'value5'
      }
      result = '?key1=value1&key2=true&key4=false&key5=value5'
      expect(subject.send(:format_options, options)).to eq(result)
    end

    it 'will return an empty string if an empty hash is given' do
      expect(subject.send(:format_options, {})).to eq('')
    end

    it 'will return an empty string if all values are empty strings' do
      options = {
        key1: '',
        key2: '',
        key3: ''
      }
      expect(subject.send(:format_options, options)).to eq('')
    end
  end

  describe '#run' do
    it 'should call CURL' do
      expect(subject).to receive(:`).and_return('{}')
      subject.send(:run, 'GET', "/projects/#{Faker::Lorem.word}")
    end

    it 'should use JSON to parse the response' do
      expect(JSON).to receive(:parse).and_return({})
      subject.send(:run, 'GET', "/projects/#{Faker::Lorem.word}")
    end

    it 'should use OpenStruct to turn the hash into an object' do
      expect(OpenStruct).to receive(:new).and_return(OpenStruct.new)
      subject.send(:run, 'GET', "/projects/#{Faker::Lorem.word}")
    end
  end

  describe '#url_encode' do
    let(:group_name) { Faker::Lorem.word }
    let(:project_name) { Faker::Lorem.word }

    it 'should return the same string as passed in but with no spaces' do
      expect(subject.send(:url_encode, "#{group_name}/#{project_name}")).to eq("#{group_name}%2F#{project_name}")
    end

    it 'should never include a space or a slash' do
      resp = subject.send(:url_encode, "#{group_name} #{Faker::Lorem.word}/#{project_name}")
      expect(resp).not_to include(' ')
      expect(resp).not_to include('/')
    end
  end

  describe '#gitlab_token' do
    it 'should return a token' do
      expect(subject.send(:gitlab_token)).to eq(:token)
    end
  end

  describe '#git_config_reader' do
    it 'should make a new git config reader' do
      expect(GitHelper::GitConfigReader).to receive(:new)
      subject.send(:git_config_reader)
    end
  end
end
