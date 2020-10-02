require 'spec_helper'
require 'git_helper'

describe GitHelper::CleanBranches do
  let(:local_code) { double(:local_code, clean_branches: :commit) }

  subject { GitHelper::CleanBranches.new }

  it 'should call GitHelper::LocalCode' do
    expect(GitHelper::LocalCode).to receive(:new).and_return(local_code)
    subject.execute
  end

  it 'should call the clean_branches method from the local code class' do
    allow(GitHelper::LocalCode).to receive(:new).and_return(local_code)
    expect(local_code).to receive(:clean_branches)
    subject.execute
  end
end
