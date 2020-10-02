require_relative '../../lib/git_helper/local_code.rb'

describe GitHelper::LocalCode do
  let(:response) { double(:response, readline: true, to_i: 5) }
  let(:local_codeent) { double(:local_code, ask: response) }
  let(:ssh_remote) { 'origin\tgit@github.com:emmasax4/git_helper.git (fetch)' }
  let(:https_remote) { 'origin\thttps://github.com/emmasax4/git_helper.git (fetch)' }
  let(:github_remotes) { ['origin\tgit@github.com:emmasax4/git_helper.git (fetch)', 'origin\thttps://github.com/emmasax4/git_helper.git (fetch)' ] }
  let(:gitlab_remotes) { ['origin\tgit@gitlab.com:emmasax4/git_helper.git (fetch)', 'origin\thttps://gitlab.com/emmasax4/git_helper.git (fetch)' ] }


  subject { GitHelper::LocalCode.new }

  before do
    allow(subject).to receive(:system).and_return(nil)
  end

  describe '#checkout_default' do
    it 'should make a system call' do
      expect(subject).to receive(:system)
      subject.checkout_default
    end
  end

  describe '#forget_local_commits' do
    it 'should make a system call' do
      expect(subject).to receive(:system).exactly(2).times
      subject.forget_local_commits
    end

    it 'should return nil' do
      expect(subject.forget_local_commits).to eq(nil)
    end
  end

  describe '#empty_commit' do
    it 'should make a system call' do
      expect(subject).to receive(:system)
      subject.empty_commit
    end
  end

  describe '#clean_branches' do
    it 'should make a system call' do
      expect(subject).to receive(:system).exactly(4).times
      subject.clean_branches
    end
  end

  describe '#new_branch' do
    it 'should make a system call' do
      expect(subject).to receive(:system).exactly(4).times
      subject.new_branch('branch_name')
    end
  end

  describe '#change_remote' do
    it 'should return a string' do
      expect(subject.change_remote('name', 'url')).to be_a(String)
    end
  end

  describe '#remotes' do
    it 'should return an array of strings' do
      expect(subject.remotes).to be_a(Array)
      expect(subject.remotes.first).to be_a(String)
    end
  end

  describe '#remote_name' do
    it 'should be a string' do
      expect(subject.remote_name(ssh_remote)).to be_a(String)
    end
  end

  describe '#ssh_remote' do
    it 'should come out true if ssh' do
      expect(subject.ssh_remote?(ssh_remote)).to eq(true)
    end

    it 'should come out false if https' do
      expect(subject.ssh_remote?(https_remote)).to eq(false)
    end
  end

  describe '#https_remote' do
    it 'should come out false if ssh' do
      expect(subject.https_remote?(ssh_remote)).to eq(false)
    end

    it 'should come out true if https' do
      expect(subject.https_remote?(https_remote)).to eq(true)
    end
  end

  describe '#remote_project' do
    it 'should return just the plain project if ssh' do
      expect(subject.remote_project(ssh_remote)).to eq('git_helper')
    end

    it 'should return just the plain project if https' do
      expect(subject.remote_project(https_remote)).to eq('git_helper')
    end
  end

  describe '#remote_source' do
    it 'should return just the plain project if ssh' do
      expect(subject.remote_source(ssh_remote)).to eq('github.com')
    end

    it 'should return just the plain project if https' do
      expect(subject.remote_source(https_remote)).to eq('github.com')
    end
  end

  describe '#github_repo' do
    it 'should return true if github' do
      allow(subject).to receive(:remotes).and_return(github_remotes)
      expect(subject.github_repo?).to eq(true)
    end

    it 'should return false if gitlab' do
      allow(subject).to receive(:remotes).and_return(gitlab_remotes)
      expect(subject.github_repo?).to eq(false)
    end
  end

  describe '#gitlab_project' do
    it 'should return true if gitlab' do
      allow(subject).to receive(:remotes).and_return(gitlab_remotes)
      expect(subject.gitlab_project?).to eq(true)
    end

    it 'should return false if github' do
      allow(subject).to receive(:remotes).and_return(github_remotes)
      expect(subject.gitlab_project?).to eq(false)
    end
  end

  describe '#name' do
    it 'should return a string' do
      expect(subject.name).to be_a(String)
    end

    it 'should equal this project name' do
      expect(subject.name).to eq('emmasax4/git_helper')
    end
  end

  describe '#branch' do
    it 'should return a string' do
      expect(subject.branch).to be_a(String)
    end
  end

  describe '#default_branch' do
    it 'should return a string' do
      expect(subject.default_branch).to be_a(String)
    end
  end

  describe '#template_options' do
    let(:template_identifiers) do
      {
        nested_directory_name: 'PULL_REQUEST_TEMPLATE',
        non_nested_file_name: 'pull_request_template'
      }
    end

    it 'should return an array' do
      expect(subject.template_options(template_identifiers)).to be_a(Array)
    end

    it 'should call Dir.glob and File.join' do
      expect(Dir).to receive(:glob).and_return(['.github/pull_request_template.md']).at_least(:once)
      expect(File).to receive(:join).at_least(:once)
      subject.template_options(template_identifiers)
    end
  end

  describe '#read_template' do
    it 'should call File.open' do
      expect(File).to receive(:open).and_return(double(read: true))
      subject.read_template('.gitignore')
    end
  end

  describe '#generate_title' do
    it 'should return a title based on the branch' do
      branch = 'jira-123-test-branch'
      expect(subject.generate_title(branch)).to eq('JIRA-123 Test branch')
    end

    it 'should return a title based on the branch' do
      branch = 'jira_123_test_branch'
      expect(subject.generate_title(branch)).to eq('JIRA-123 Test branch')
    end

    it 'should return a title based on the branch' do
      branch = 'jira-123_test_branch'
      expect(subject.generate_title(branch)).to eq('JIRA-123 Test branch')
    end

    it 'should return a title based on the branch' do
      branch = 'test_branch'
      expect(subject.generate_title(branch)).to eq('Test branch')
    end

    it 'should return a title based on the branch' do
      branch = 'test-branch'
      expect(subject.generate_title(branch)).to eq('Test branch')
    end

    it 'should return a title based on the branch' do
      branch = 'test'
      expect(subject.generate_title(branch)).to eq('Test')
    end

    it 'should return a title based on the branch' do
      branch = 'some_other_words_in_this_test_branch'
      expect(subject.generate_title(branch)).to eq('Some other words in this test branch')
    end

    it 'should return a title based on the branch' do
      branch = 'some-other-words-in-this-test-branch'
      expect(subject.generate_title(branch)).to eq('Some other words in this test branch')
    end
  end
end
