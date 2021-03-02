# frozen_string_literal: true

require 'spec_helper'
require 'git_helper'

describe GitHelper::NewBranch do
  let(:new_branch_name) { 'new-branch-name' }
  let(:local_code) { double(:local_code, new_branch: :commit) }
  let(:highline) { double(:highline_wrapper, ask: new_branch_name) }

  subject { GitHelper::NewBranch.new }

  before do
    allow(GitHelper::LocalCode).to receive(:new).and_return(local_code)
    allow(HighlineWrapper).to receive(:new).and_return(highline)
    allow(subject).to receive(:puts)
  end

  it 'should call GitHelper::LocalCode' do
    expect(GitHelper::LocalCode).to receive(:new).and_return(local_code)
    subject.execute
  end

  it 'should call the new_branch method from the local code class' do
    expect(local_code).to receive(:new_branch)
    subject.execute
  end

  context 'when no branch name is passed in' do
    it 'should call the highline client' do
      expect(HighlineWrapper).to receive(:new).and_return(highline)
      subject.execute
    end

    it 'should ask the highline client what the new branch name should be' do
      expect(highline).to receive(:ask)
      subject.execute
    end
  end

  context 'when there is a branch name passed in' do
    it 'should not create a highline_wrapper client' do
      expect(HighlineWrapper).not_to receive(:new)
      subject.execute(new_branch_name)
    end
  end
end
