require 'spec_helper'
require 'git_helper'

describe GitHelper::HighlineCli do
  let(:response) { double(:response, readline: true, to_i: 5) }
  let(:highline_client) { double(:highline_cli, ask: response) }

  subject { GitHelper::HighlineCli.new }

  before do
    allow(HighLine).to receive(:new).and_return(highline_client)
  end

  describe '#new_branch_name' do
    it 'should ask the subjects ask method' do
      expect(subject).to receive(:ask).with('New branch name?')
      subject.new_branch_name
    end

    it 'should come out a string' do
      expect(subject.new_branch_name).to be_a(String)
    end
  end

  describe '#process_directory_remotes' do
    it 'should ask the subjects ask method' do
      expect(subject).to receive(:ask).and_return('y')
      subject.process_directory_remotes?(Faker::Lorem.word)
    end

    it 'should be a boolean at the end' do
      allow(subject).to receive(:ask).and_return('y')
      expect([true, false]).to include(subject.process_directory_remotes?(Faker::Lorem.word))
    end

    it 'should come out as a true boolean if somebody responds y' do
      allow(subject).to receive(:ask).and_return('y')
      expect(subject.process_directory_remotes?(Faker::Lorem.word)).to eq(true)
    end

    it 'should come out as a false boolean if somebody responds n' do
      allow(subject).to receive(:ask).and_return('n')
      expect(subject.process_directory_remotes?(Faker::Lorem.word)).to eq(false)
    end

    it 'should come out as true if somebody presses enter' do
      allow(subject).to receive(:ask).and_return('')
      expect(subject.accept_autogenerated_title?(Faker::Lorem.word)).to eq(true)
    end
  end

  describe '#conflicting_remote_clarification' do
    it 'should ask the subjects ask method' do
      expect(subject).to receive(:ask).with('Found git remotes for both GitHub and GitLab. Would you like to proceed with GitLab or GitHub? (github/gitlab)').and_return('gitlab')
      subject.conflicting_remote_clarification
    end

    it 'should come out a string' do
      expect(subject.conflicting_remote_clarification).to be_a(String)
    end
  end

  describe '#title' do
    it 'should ask the subjects ask method' do
      expect(subject).to receive(:ask).with('Title?')
      subject.title
    end

    it 'should come out a string' do
      expect(subject.title).to be_a(String)
    end
  end

  describe '#base_branch' do
    it 'should ask the subjects ask method' do
      expect(subject).to receive(:ask).with('Base branch?')
      subject.base_branch
    end

    it 'should come out a string' do
      expect(subject.base_branch).to be_a(String)
    end
  end

  describe '#code_request_id' do
    let(:phrase) { Faker::Lorem.sentence }

    it 'should ask the subjects ask method' do
      expect(subject).to receive(:ask).with("#{phrase} Request ID?")
      subject.code_request_id(phrase)
    end

    it 'should come out a string' do
      expect(subject.code_request_id(phrase)).to be_a(String)
    end
  end

  describe '#accept_autogenerated_title' do
    it 'should ask the subjects ask method' do
      expect(subject).to receive(:ask).and_return('y')
      subject.accept_autogenerated_title?(Faker::Lorem.sentence)
    end

    it 'should be a boolean at the end' do
      allow(subject).to receive(:ask).and_return('y')
      expect([true, false]).to include(subject.accept_autogenerated_title?(Faker::Lorem.sentence))
    end

    it 'should come out as a true boolean if somebody responds y' do
      allow(subject).to receive(:ask).and_return('y')
      expect(subject.accept_autogenerated_title?(Faker::Lorem.sentence)).to eq(true)
    end

    it 'should come out as a true boolean if somebody responds n' do
      allow(subject).to receive(:ask).and_return('n')
      expect(subject.accept_autogenerated_title?(Faker::Lorem.sentence)).to eq(false)
    end

    it 'should come out as a true boolean if somebody responds yes' do
      allow(subject).to receive(:ask).and_return('yes')
      expect(subject.accept_autogenerated_title?(Faker::Lorem.sentence)).to eq(true)
    end

    it 'should come out as a false boolean if somebody responds no' do
      allow(subject).to receive(:ask).and_return('no')
      expect(subject.accept_autogenerated_title?(Faker::Lorem.sentence)).to eq(false)
    end

    it 'should come out as true if somebody presses enter' do
      allow(subject).to receive(:ask).and_return('')
      expect(subject.accept_autogenerated_title?(Faker::Lorem.sentence)).to eq(true)
    end
  end

  describe '#base_branch_default' do
    it 'should ask the subjects ask method' do
      expect(subject).to receive(:ask).and_return('y')
      subject.base_branch_default?(Faker::Lorem.word)
    end

    it 'should be a boolean at the end' do
      allow(subject).to receive(:ask).and_return('y')
      expect([true, false]).to include(subject.base_branch_default?(Faker::Lorem.word))
    end

    it 'should come out as a true boolean if somebody responds y' do
      allow(subject).to receive(:ask).and_return('y')
      expect(subject.base_branch_default?(Faker::Lorem.word)).to eq(true)
    end

    it 'should come out as a true boolean if somebody responds n' do
      allow(subject).to receive(:ask).and_return('n')
      expect(subject.base_branch_default?(Faker::Lorem.word)).to eq(false)
    end

    it 'should come out as a true boolean if somebody responds yes' do
      allow(subject).to receive(:ask).and_return('yes')
      expect(subject.base_branch_default?(Faker::Lorem.word)).to eq(true)
    end

    it 'should come out as a false boolean if somebody responds no' do
      allow(subject).to receive(:ask).and_return('no')
      expect(subject.base_branch_default?(Faker::Lorem.word)).to eq(false)
    end

    it 'should come out as true if somebody presses enter' do
      allow(subject).to receive(:ask).and_return('')
      expect(subject.base_branch_default?(Faker::Lorem.word)).to eq(true)
    end
  end

  describe '#merge_method' do
    it 'should ask the subjects ask_options method' do
      expect(subject).to receive(:ask_options).and_return(3)
      subject.merge_method(['1', '2', '3'])
    end

    it 'should return a string' do
      allow(subject).to receive(:ask_options).and_return(2)
      expect(subject.merge_method(['1', '2', '3'])).to be_a(String)
    end
  end

  describe '#template_to_apply' do
    it 'should ask the subjects ask_options method' do
      expect(subject).to receive(:ask_options).and_return(3)
      subject.template_to_apply(['option1', 'option2', 'option3'], 'example type')
    end

    it 'should return a string' do
      allow(subject).to receive(:ask_options).and_return(3)
      expect(subject.template_to_apply(['option1', 'option2', 'option3'], 'example type')).to eq('None')
    end
  end

  describe '#ask' do
    it 'should ask the highline client ask'do
      expect(highline_client).to receive(:ask)
      subject.send(:ask, Faker::Lorem.sentence)
    end

    it 'should return a string' do
      expect(subject.send(:ask, Faker::Lorem.sentence)).to be_a(String)
    end
  end

  describe '#ask_options' do
    it 'should ask the highline client ask'do
      expect(highline_client).to receive(:ask)
      subject.send(:ask_options, Faker::Lorem.sentence, ['1', '2', '3'])
    end

    it 'should return an integer' do
      expect(subject.send(:ask_options, Faker::Lorem.sentence, ['1', '2', '3'])).to be_a(Integer)
    end
  end
end
