require 'spec_helper'
require 'git_helper'

describe GitHelper::NewBranch do
  let(:new_branch_name) { 'new-branch-name' }
  let(:local_code) { double(:local_code, new_branch: :commit) }
  let(:cli) { double(:highline_cli, ask: new_branch_name) }

  subject { GitHelper::NewBranch.new }

  before do
    allow(GitHelper::LocalCode).to receive(:new).and_return(local_code)
    allow(GitHelper::HighlineCli).to receive(:new).and_return(cli)
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
    it 'should call the highline cli' do
      expect(GitHelper::HighlineCli).to receive(:new).and_return(cli)
      subject.execute
    end

    it 'should ask the highline cli what the new branch name should be' do
      expect(cli).to receive(:ask)
      subject.execute
    end
  end

  context 'when there is a branch name passed in' do
    it 'should not create a highline cli' do
      expect(GitHelper::HighlineCli).not_to receive(:new)
      subject.execute(new_branch_name)
    end
  end
end
