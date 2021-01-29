require 'spec_helper'
require 'git_helper'

describe GitHelper::HighlineCli do
  let(:response) { double(:response, readline: true, to_i: 3) }
  let(:highline_client) { double(:highline_cli, ask: response) }

  subject { GitHelper::HighlineCli.new }

  before do
    allow(HighLine).to receive(:new).and_return(highline_client)
  end

  describe '#ask' do
    it 'should ask the highline client ask'do
      expect(highline_client).to receive(:ask)
      subject.ask(Faker::Lorem.sentence)
    end

    it 'should return a string' do
      expect(subject.ask(Faker::Lorem.sentence)).to be_a(String)
    end
  end

  describe '#ask_yes_no' do
    it 'should ask the highline client ask'do
      expect(highline_client).to receive(:ask)
      subject.ask_yes_no(Faker::Lorem.sentence)
    end

    it 'should return a boolean' do
      expect(subject.ask_yes_no(Faker::Lorem.sentence)).to be_falsey
    end

    it 'should return true if we say yes' do
      allow(response).to receive(:to_s).and_return('y')
      expect(subject.ask_yes_no(Faker::Lorem.sentence)).to be_truthy
    end
  end

  describe '#ask_options' do
    it 'should ask the highline client ask'do
      expect(highline_client).to receive(:ask)
      subject.ask_options(Faker::Lorem.sentence, ['one', 'two', 'three'])
    end

    it 'should return a string from the options' do
      expect(subject.ask_options(Faker::Lorem.sentence, ['one', 'two', 'three'])).to be_a(String)
    end
  end
end
