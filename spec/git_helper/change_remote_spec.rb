require 'spec_helper'
require 'git_helper'

describe GitHelper::ChangeRemote do
  let(:remote1) { "git@github.com:#{old_owner}/#{project}.git" }
  let(:project) { Faker::Lorem.word }
  let(:cli) { double(:highline_cli, ask_yes_no: true) }
  let(:old_owner) { Faker::Internet.username }
  let(:new_owner) { Faker::Internet.username }
  let(:directory_entries) { [ '.', '..', project, Faker::Lorem.word, Faker::Lorem.word ] }

  let(:local_code) do
    double(:local_code,
      remotes: [remote1],
      remote_name: Faker::Lorem.word,
      ssh_remote?: true,
      https_remote?: false,
      remote_project: project,
      remote_source: 'github.com',
      change_remote: true
    )
  end

  subject { GitHelper::ChangeRemote.new(old_owner, new_owner) }

  before do
    allow(GitHelper::HighlineCli).to receive(:new).and_return(cli)
    allow(GitHelper::LocalCode).to receive(:new).and_return(local_code)
    allow(subject).to receive(:puts)
  end

  describe '#execute' do
    before do
      allow(Dir).to receive(:pwd).and_return("/Users/#{Faker::Name.first_name}/#{project}")
      allow(Dir).to receive(:entries).and_return(directory_entries)
      allow(File).to receive(:join).and_return("/Users/#{Faker::Name.first_name}/#{project}/#{Faker::Lorem.word}")
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
      subject.send(:process_dir, "/Users/#{Faker::Name.first_name}/#{project}", "/Users/#{Faker::Name.first_name}/#{project}/#{Faker::Lorem.word}")
    end

    context 'when the user says to process the directory' do
      it 'should call to process the git repository at least once' do
        expect(subject).to receive(:process_git_repository).at_least(:once)
        subject.send(:process_dir, "/Users/#{Faker::Name.first_name}/#{project}", "/Users/#{Faker::Name.first_name}/#{project}/#{Faker::Lorem.word}")
      end
    end

    context 'when the user says not to process the directory' do
      let(:cli) { double(:highline_cli, ask_yes_no: false) }

      it 'should not call to process the directory' do
        expect(subject).not_to receive(:process_git_repository)
        subject.send(:process_dir, "/Users/#{Faker::Name.first_name}/#{project}", "/Users/#{Faker::Name.first_name}/#{project}/#{Faker::Lorem.word}")
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
      let(:remote1) { "git@github.com:#{new_owner}/#{project}.git" }

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
      expect(local_code).to receive(:remote_project).exactly(:once)
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
          remote_name: Faker::Lorem.word,
          ssh_remote?: false,
          https_remote?: false,
          remote_project: project,
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
