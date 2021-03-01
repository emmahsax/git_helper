# frozen_string_literal: true

require 'spec_helper'
require 'git_helper'

describe GitHelper::Setup do
  let(:response) { double(:response, readline: true, to_s: Faker::Lorem.sentence) }
  let(:highline_cli) { double(:highline_cli, ask: response, ask_yes_no: true) }

  before do
    allow(GitHelper::HighlineCli).to receive(:new).and_return(highline_cli)
    allow(subject).to receive(:puts)
  end

  after do
    GitHelper::Setup.instance_variable_set('@highline', nil)
  end

  describe '#execute' do
    it 'should ask a question if the config file exists' do
      allow(File).to receive(:exists?).and_return(true)
      expect(highline_cli).to receive(:ask_yes_no).and_return(true)
      allow(subject).to receive(:create_or_update_config_file).and_return(true)
      allow(subject).to receive(:create_or_update_plugin_files)
      subject.execute
    end

    it 'should call to create or update the config file' do
      allow(File).to receive(:exists?).and_return(true)
      allow(highline_cli).to receive(:ask_yes_no).and_return(true)
      expect(subject).to receive(:create_or_update_config_file).and_return(true)
      allow(subject).to receive(:create_or_update_plugin_files)
      subject.execute
    end

    it 'should skip if the user opts not to continue' do
      allow(File).to receive(:exists?).and_return(true)
      allow(highline_cli).to receive(:ask_yes_no).and_return(false)
      expect(subject).not_to receive(:create_or_update_config_file)
      expect(subject).not_to receive(:create_or_update_plugin_files)
      subject.execute
    end
  end

  describe '#create_or_update_config_file' do
    it 'should generate the file based on the answers to the questions' do
      expect(subject).to receive(:generate_file_contents)
      allow(File).to receive(:open).and_return(nil)
      subject.send(:create_or_update_config_file)
    end

    it 'should open the file for writing' do
      allow(subject).to receive(:generate_file_contents)
      expect(File).to receive(:open).and_return(nil)
      subject.send(:create_or_update_config_file)
    end
  end

  describe '#config_file_exists?' do
    it 'should return true if the file exists' do
      allow(File).to receive(:exists?).and_return(true)
      expect(subject.send(:config_file_exists?)).to eq(true)
    end

    it 'should return false if the file does not exist' do
      allow(File).to receive(:exists?).and_return(false)
      expect(subject.send(:config_file_exists?)).to eq(false)
    end
  end

  describe '#ask_question' do
    it 'should use highline to ask a question' do
      expect(highline_cli).to receive(:ask).and_return(Faker::Lorem.word)
      subject.send(:ask_question, Faker::Lorem.sentence)
    end

    it 'should recurse if the highline client gets an empty string' do
      allow(highline_cli).to receive(:ask).and_return('', Faker::Lorem.word)
      expect(subject).to receive(:ask_question).at_least(:twice).and_call_original
      subject.send(:ask_question, Faker::Lorem.sentence)
    end

    it 'should return the answer if it is given' do
      answer = Faker::Lorem.sentence
      allow(highline_cli).to receive(:ask).and_return(answer)
      expect(subject.send(:ask_question, Faker::Lorem.sentence)).to be(answer)
    end
  end

  describe '#generate_file_contents' do
    it 'should ask two yes/no questions' do
      expect(highline_cli).to receive(:ask_yes_no).exactly(2).times.and_return(false)
      subject.send(:generate_file_contents)
    end

    it 'should ask two additional questions for each time the user says yes' do
      allow(highline_cli).to receive(:ask_yes_no).exactly(2).times.and_return(true, false)
      expect(subject).to receive(:ask_question).exactly(2).times.and_return(Faker::Lorem.word)
      subject.send(:generate_file_contents)
    end

    it 'should ask four additional questions for each time the user says yes' do
      allow(highline_cli).to receive(:ask_yes_no).exactly(2).times.and_return(true)
      expect(subject).to receive(:ask_question).exactly(4).times.and_return(Faker::Lorem.word)
      subject.send(:generate_file_contents)
    end

    it 'should return a string no matter what' do
      allow(highline_cli).to receive(:ask_yes_no).exactly(2).times.and_return(true)
      allow(subject).to receive(:ask_question).exactly(4).times.and_return(Faker::Lorem.word)
      expect(subject.send(:generate_file_contents)).to be_a(String)
    end
  end

  describe '#create_or_update_plugin_files' do
    let(:plugins) do
      [
        {
          name: 'plugin-file-one'
        },
        {
          name: 'plugin-file-two'
        }
      ]
    end

    let(:plugins_json) do
      "[
        {
          \"name\": \"plugin-file-one\"
        },
        {
          \"name\": \"plugin-file-two\"
        }
      ]"
    end

    before do
      allow_any_instance_of(GitHelper::GitConfigReader).to receive(:github_token).and_return(Faker::Internet.password)
      allow_any_instance_of(GitHelper::GitConfigReader).to receive(:github_user).and_return(Faker::Internet.username)
    end

    it 'should create the directory if it does not exist' do
      allow(File).to receive(:exists?).and_return(false)
      allow(File).to receive(:open).and_return(nil)
      expect(Dir).to receive(:mkdir)
      allow(subject).to receive(:`).and_return(plugins_json)
      allow(JSON).to receive(:parse).and_return(plugins)
      subject.send(:create_or_update_plugin_files)
    end

    it 'should not create the directory if it already exists' do
      allow(File).to receive(:exists?).and_return(true)
      allow(File).to receive(:open).and_return(nil)
      expect(Dir).not_to receive(:mkdir)
      allow(subject).to receive(:`).and_return(plugins_json)
      allow(JSON).to receive(:parse).and_return(plugins)
      subject.send(:create_or_update_plugin_files)
    end

    it 'should curl the GitHub API' do
      allow(File).to receive(:exists?).and_return(true)
      allow(File).to receive(:open).and_return(nil)
      allow(subject).to receive(:`).and_return(plugins_json)
      expect(JSON).to receive(:parse).with(plugins_json).and_return(plugins)
      subject.send(:create_or_update_plugin_files)
    end

    it 'should go through the loop for each plugin' do
      allow(File).to receive(:exists?).and_return(true)
      allow(File).to receive(:open).and_return(nil)
      expect(subject).to receive(:`).exactly(3).times
      allow(JSON).to receive(:parse).and_return(plugins)
      subject.send(:create_or_update_plugin_files)
    end
  end
end
