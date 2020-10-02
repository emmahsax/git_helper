require_relative '../../lib/git_helper/empty_commit.rb'

describe GitHelper::EmptyCommit do
  let(:local_code) { double(:local_code, empty_commit: :commit) }

  subject { GitHelper::EmptyCommit.new }

  it 'should call GitHelper::LocalCode' do
    expect(GitHelper::LocalCode).to receive(:new).and_return(local_code)
    subject.execute
  end

  it 'should call the empty_commit method from the local code class' do
    allow(GitHelper::LocalCode).to receive(:new).and_return(local_code)
    expect(local_code).to receive(:empty_commit)
    subject.execute
  end
end
