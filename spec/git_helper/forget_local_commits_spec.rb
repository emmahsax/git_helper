require_relative '../../lib/git_helper/forget_local_commits.rb'

describe GitHelper::ForgetLocalCommits do
  let(:local_code) { double(:local_code, forget_local_commits: :commit) }

  subject { GitHelper::ForgetLocalCommits.new }

  it 'should call GitHelper::LocalCode' do
    expect(GitHelper::LocalCode).to receive(:new).and_return(local_code)
    subject.execute
  end

  it 'should call the forget_local_commits method from the local code class' do
    allow(GitHelper::LocalCode).to receive(:new).and_return(local_code)
    expect(local_code).to receive(:forget_local_commits)
    subject.execute
  end
end
