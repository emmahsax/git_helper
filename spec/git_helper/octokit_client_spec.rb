require_relative '../../lib/git_helper/octokit_client.rb'

describe GitHelper::OctokitClient do
  let(:git_config_reader) { double(:git_config_reader, github_token: :token) }

  subject { GitHelper::OctokitClient.new }

  before do
    allow(GitHelper::GitConfigReader).to receive(:new).and_return(git_config_reader)
  end

  describe '#client' do
    it 'should call the GitLab client to make a new client' do
      expect(Octokit::Client).to receive(:new)
      subject.client
    end
  end

  describe '#git_config_reader' do
    it 'should make a new git config reader' do
      expect(GitHelper::GitConfigReader).to receive(:new)
      subject.send(:git_config_reader)
    end
  end
end
