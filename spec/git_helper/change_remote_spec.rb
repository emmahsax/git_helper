require_relative '../../lib/git_helper/change_remote.rb'

describe GitHelper::ChangeRemote do
  let(:remote1) { 'git@github.com:github-username-old/project-1.git' }
  let(:local_code) do
    double(:local_code,
      remotes: [remote1],
      remote_name: 'origin',
      ssh_remote?: true,
      https_remote?: false,
      remote_repo: 'project-1',
      remote_source: 'github.com',
      change_remote: true
    )
  end
  let(:cli) { double(:highline_cli, process_directory_remotes?: true) }
  let(:old_owner) { 'github-username-old' }
  let(:new_owner) { 'github-username-new' }
  let(:directory_entries) { [ '.', '..', 'project-1', 'project-2', 'project-3' ] }

  subject { GitHelper::ChangeRemote.new(old_owner, new_owner) }

  before do
    allow(GitHelper::HighlineCli).to receive(:new).and_return(cli)
    allow(GitHelper::LocalCode).to receive(:new).and_return(local_code)
  end

  describe '#execute' do
    before do
      allow(Dir).to receive(:pwd).and_return('/Users/firstname/lastname/path/to/project')
      allow(Dir).to receive(:entries).and_return(directory_entries)
      allow(File).to receive(:join).and_return('/Users/firstname/lastname/path/to/project/project-1')
      allow(File).to receive(:directory?).and_return(true)
      allow(subject).to receive(:process_dir)
    end

    it 'should call to process at least one directory' do
      expect(subject).to receive(:process_dir).at_least(:once)
      subject.execute
    end

    it 'should definitely look in the file structure' do
      expect(Dir).to receive(:pwd)
      expect(Dir).to receive(:entries)
      expect(File).to receive(:join)
      expect(File).to receive(:directory?)
      subject.execute
    end
  end

  describe '#process_dir' do
    before do
      allow(Dir).to receive(:chdir).and_return(nil)
      allow(File).to receive(:exist?).and_return(true)
      allow(subject).to receive(:process_git_repository)
    end

    it 'should definitely look in the file structure' do
      expect(Dir).to receive(:chdir)
      expect(File).to receive(:exist?)
      subject.send(:process_dir, '/Users/firstname/lastname/path/to/project', '/Users/firstname/lastname/path/to/project/project-1')
    end

    context 'when the user says to process the directory' do
      it 'should call to process the git repository at least once' do
        expect(subject).to receive(:process_git_repository).at_least(:once)
        subject.send(:process_dir, '/Users/firstname/lastname/path/to/project', '/Users/firstname/lastname/path/to/project/project-1')
      end
    end

    context 'when the user says not to process the directory' do
      let(:cli) { double(:highline_cli, process_directory_remotes?: false) }

      it 'should not call to process the directory' do
        expect(subject).not_to receive(:process_git_repository)
        subject.send(:process_dir, '/Users/firstname/lastname/path/to/project', '/Users/firstname/lastname/path/to/project/project-1')
      end
    end
  end

  describe '#process_git_repository' do
    before do
      allow(subject).to receive(:process_remote).and_return(nil)
    end

    it 'should call local_code' do
      expect(GitHelper::LocalCode).to receive(:new)
      subject.send(:process_git_repository)
    end

    context 'when the remote includes the old owner' do
      it 'should call to process the remote' do
        expect(subject).to receive(:process_remote)
        subject.send(:process_git_repository)
      end
    end

    context 'when the remote does not include the old owner' do
      let(:remote1) { 'git@github.com:github-username-new/project-1.git' }

      it 'should not call to process the remote' do
        expect(subject).not_to receive(:process_remote)
        subject.send(:process_git_repository)
      end
    end
  end

  describe '#process_remote' do
    it 'should always get the remote name' do
      expect(local_code).to receive(:remote_name)
      subject.send(:process_remote, remote1)
    end

    it 'should always attempt to change the remote' do
      expect(local_code).to receive(:change_remote)
      subject.send(:process_remote, remote1)
    end

    it 'should attempt to get the remote repo exactly once' do
      expect(local_code).to receive(:remote_repo).exactly(:once)
      subject.send(:process_remote, remote1)
    end

    it 'should attempt to get the remote source exactly once' do
      expect(local_code).to receive(:remote_source).exactly(:once)
      subject.send(:process_remote, remote1)
    end

    it 'should ask if the remote is SSH' do
      expect(local_code).to receive(:ssh_remote?)
      subject.send(:process_remote, remote1)
    end

    context 'https remote' do
      let(:local_code) do
        double(:local_code,
          remotes: [remote1],
          remote_name: 'origin',
          ssh_remote?: false,
          https_remote?: false,
          remote_repo: 'project-1',
          remote_source: 'github.com',
          change_remote: true
        )
      end

      it 'should ask if the remote is SSH' do
        expect(local_code).to receive(:ssh_remote?)
        subject.send(:process_remote, remote1)
      end

      it 'should ask if the remote is https' do
        expect(local_code).to receive(:https_remote?)
        subject.send(:process_remote, remote1)
      end
    end
  end

  describe '#local_code' do
    it 'should create a new local code instance' do
      expect(GitHelper::LocalCode).to receive(:new)
      subject.send(:local_code)
    end
  end

  describe '#cli' do
    it 'should create a new highline CLI instance' do
      expect(GitHelper::HighlineCli).to receive(:new)
      subject.send(:cli)
    end
  end
end
