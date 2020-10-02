require_relative '../../lib/git_helper/code_request.rb'

describe GitHelper::CodeRequest do
  let(:highline_cli) { double(:highline_cli) }
  let(:local_code) { double(:local_code, project_name: 'name', branch: 'branch') }
  let(:process_project) { double(:process_project, create: :created, merge: :merged) }

  subject { GitHelper::CodeRequest.new }

  before do
    allow(GitHelper::LocalCode).to receive(:new).and_return(local_code)
    allow(GitHelper::HighlineCli).to receive(:new).and_return(highline_cli)
  end

  describe '#create' do
    before do
      allow(subject).to receive(:base_branch).and_return('base')
      allow(subject).to receive(:new_code_request_title).and_return('Title')
    end

    it 'should call to process the project' do
      expect(subject).to receive(:process_project).and_return(process_project)
      subject.create
    end

    it 'should call create' do
      allow(subject).to receive(:process_project).and_return(process_project)
      expect(process_project).to receive(:create)
      subject.create
    end

    it 'should call base_branch and new_code_request_title' do
      expect(subject).to receive(:base_branch).and_return('base')
      expect(subject).to receive(:new_code_request_title).and_return('Title')
      allow(subject).to receive(:process_project).and_return(process_project)
      allow(process_project).to receive(:create)
      subject.create
    end
  end

  describe '#merge' do
    it 'should call to process the project' do
      expect(subject).to receive(:process_project).and_return(process_project)
      subject.merge
    end

    it 'should call merge' do
      allow(subject).to receive(:process_project).and_return(process_project)
      expect(process_project).to receive(:merge)
      subject.merge
    end
  end

  describe '#process_project' do
    it 'should call the local code to see if it is a github or gitlab project' do
      expect(local_code).to receive(:gitlab_project?).and_return(false)
      expect(local_code).to receive(:github_repo?).and_return(true)
      subject.send(:process_project)
    end

    context 'when github and gitlab remotes are found' do
      it 'should ask for clarification' do
        allow(local_code).to receive(:gitlab_project?).and_return(true)
        allow(local_code).to receive(:github_repo?).and_return(true)
        expect(subject).to receive(:ask_for_clarification)
        subject.send(:process_project)
      end
    end

    context 'when github' do
      it 'should call the github_pull_request' do
        allow(local_code).to receive(:gitlab_project?).and_return(false)
        allow(local_code).to receive(:github_repo?).and_return(true)
        expect(subject).to receive(:github_pull_request)
        subject.send(:process_project)
      end
    end

    context 'when gitlab' do
      it 'should call the gitlab_merge_request' do
        allow(local_code).to receive(:gitlab_project?).and_return(true)
        allow(local_code).to receive(:github_repo?).and_return(false)
        expect(subject).to receive(:gitlab_merge_request)
        subject.send(:process_project)
      end
    end

    context 'when no github or gitlab remotes are found' do
      it 'should raise error' do
        allow(local_code).to receive(:gitlab_project?).and_return(false)
        allow(local_code).to receive(:github_repo?).and_return(false)
        expect { subject.send(:process_project) }.to raise_error(StandardError)
      end
    end
  end

  describe '#ask_for_clarification' do
    it 'should ask the CLI' do
      expect(highline_cli).to receive(:conflicting_remote_clarification).and_return('github')
      subject.send(:ask_for_clarification)
    end

    context 'when response is github' do
      it 'should return github_pull_request' do
        allow(highline_cli).to receive(:conflicting_remote_clarification).and_return('github')
        expect(subject).to receive(:github_pull_request)
        subject.send(:ask_for_clarification)
      end

      it 'should return github_pull_request' do
        allow(highline_cli).to receive(:conflicting_remote_clarification).and_return('Github')
        expect(subject).to receive(:github_pull_request)
        subject.send(:ask_for_clarification)
      end
    end

    context 'when response is gitlab' do
      it 'should return gitlab_merge_request' do
        allow(highline_cli).to receive(:conflicting_remote_clarification).and_return('gitlab')
        expect(subject).to receive(:gitlab_merge_request)
        subject.send(:ask_for_clarification)
      end

      it 'should return gitlab_merge_request' do
        allow(highline_cli).to receive(:conflicting_remote_clarification).and_return('Gitlab')
        expect(subject).to receive(:gitlab_merge_request)
        subject.send(:ask_for_clarification)
      end
    end

    context 'when response is neither' do
      it 'should raise an error' do
        allow(highline_cli).to receive(:conflicting_remote_clarification).and_return('huh?')
        expect { subject.send(:ask_for_clarification) }.to raise_error(StandardError)
      end
    end
  end

  describe '#github_pull_request' do
    it 'should call the GitHelper::GitHubPullRequest' do
      expect(GitHelper::GitHubPullRequest).to receive(:new)
      subject.send(:github_pull_request)
    end
  end

  describe '#gitlab_merge_request' do
    it 'should call the GitHelper::GitLabMergeRequest' do
      expect(GitHelper::GitLabMergeRequest).to receive(:new)
      subject.send(:gitlab_merge_request)
    end
  end

  describe '#local_project' do
    it 'should call the name of the local_code' do
      expect(local_code).to receive(:project_name)
      subject.send(:local_project)
    end
  end

  describe '#default_branch' do
    it 'should call the name of the local_code' do
      expect(local_code).to receive(:default_branch)
      subject.send(:default_branch)
    end
  end

  describe '#base_branch' do
    it 'should call the default branch' do
      expect(subject).to receive(:default_branch)
      allow(highline_cli).to receive(:base_branch_default?).at_least(:once)
      allow(highline_cli).to receive(:base_branch).at_least(:once).and_return('base')
      subject.send(:base_branch)
    end

    it 'should ask the CLI to ask the user' do
      allow(subject).to receive(:default_branch)
      expect(highline_cli).to receive(:base_branch_default?).at_least(:once)
      allow(highline_cli).to receive(:base_branch).at_least(:once).and_return('base')
      subject.send(:base_branch)
    end

    context 'if the user says no' do
      it "definitely asks for the user's base branch" do
        allow(subject).to receive(:default_branch)
        expect(highline_cli).to receive(:base_branch_default?).at_least(:once).and_return(false)
        expect(highline_cli).to receive(:base_branch).at_least(:once).and_return('base')
        subject.send(:base_branch)
      end
    end

    context 'if the user says yes' do
      it "does not ask for the user's base branch" do
        allow(subject).to receive(:default_branch)
        expect(highline_cli).to receive(:base_branch_default?).at_least(:once).and_return(true)
        expect(highline_cli).not_to receive(:base_branch)
        subject.send(:base_branch)
      end
    end
  end

  describe '#autogenerated_title' do
    it 'should generate a title based on the branch' do
      expect(subject).to receive(:local_branch).and_return('branch')
      expect(local_code).to receive(:generate_title)
      subject.send(:autogenerated_title)
    end
  end

  describe '#new_code_request_title' do
    it 'should call autogenerated title method' do
      expect(subject).to receive(:autogenerated_title)
      allow(highline_cli).to receive(:accept_autogenerated_title?).at_least(:once)
      allow(highline_cli).to receive(:title).at_least(:once).and_return('Title')
      subject.send(:new_code_request_title)
    end

    it 'should ask the CLI to ask the user' do
      allow(subject).to receive(:autogenerated_title)
      expect(highline_cli).to receive(:accept_autogenerated_title?).at_least(:once)
      allow(highline_cli).to receive(:title).at_least(:once).and_return('Title')
      subject.send(:new_code_request_title)
    end

    context 'if the user says no' do
      it "definitely asks for the user's title" do
        allow(subject).to receive(:autogenerated_title)
        expect(highline_cli).to receive(:accept_autogenerated_title?).at_least(:once).and_return(false)
        expect(highline_cli).to receive(:title).at_least(:once).and_return('Title')
        subject.send(:new_code_request_title)
      end
    end

    context 'if the user says yes to original title' do
      it "does not ask for the user's chosen title" do
        allow(subject).to receive(:autogenerated_title)
        expect(highline_cli).to receive(:accept_autogenerated_title?).at_least(:once).and_return(true)
        expect(highline_cli).not_to receive(:title)
        subject.send(:new_code_request_title)
      end
    end
  end

  describe '#local_code' do
    it 'should call the octokit client' do
      expect(GitHelper::LocalCode).to receive(:new).and_return(local_code)
      subject.send(:local_code)
    end
  end

  describe '#cli' do
    it 'should call the octokit client' do
      expect(GitHelper::HighlineCli).to receive(:new).and_return(highline_cli)
      subject.send(:cli)
    end
  end
end
