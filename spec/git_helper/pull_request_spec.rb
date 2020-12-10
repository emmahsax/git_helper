require 'spec_helper'
require 'git_helper'

describe GitHelper::GitHubPullRequest do
  let(:local_code) { double(:local_code, read_template: Faker::Lorem.word) }
  let(:highline_cli) { double(:highline_cli) }
  let(:octokit_client_client) { double(:octokit_client_client, project: :project, merge_request: :merge_request, create_merge_request: :created) }
  let(:octokit_client) { double(:octokit_client, client: octokit_client_client) }

  let(:options) do
    {
      local_project: Faker::Lorem.word,
      local_branch: Faker::Lorem.word,
      local_code: local_code,
      cli: highline_cli
    }
  end

  subject { GitHelper::GitHubPullRequest.new(options) }

  before do
    allow(GitHelper::OctokitClient).to receive(:new).and_return(octokit_client)
    allow(subject).to receive(:puts)
  end

  describe '#create' do
    it 'should call the octokit client to create' do
      allow(subject).to receive(:new_pr_body).and_return('')
      expect(octokit_client_client).to receive(:create_pull_request).and_return(double(html_url: Faker::Internet.url))
      subject.create({base_branch: Faker::Lorem.word, new_title: Faker::Lorem.word})
    end

    it 'should call various other methods' do
      expect(subject).to receive(:new_pr_body).and_return('').at_least(:once)
      allow(octokit_client_client).to receive(:create_pull_request).and_return(double(html_url: Faker::Internet.url))
      subject.create({base_branch: Faker::Lorem.word, new_title: Faker::Lorem.word})
    end

    it 'should catch the raised error if the creation does not work' do
      allow(subject).to receive(:new_pr_body).and_return('')
      allow(octokit_client_client).to receive(:create_pull_request).and_raise(StandardError)
      expect(subject.create({base_branch: Faker::Lorem.word, new_title: Faker::Lorem.word})).to eq(nil)
    end
  end

  describe '#merge' do
    it 'should call the octokit client to merge' do
      allow(subject).to receive(:existing_pr).and_return(double(title: Faker::Lorem.word))
      allow(subject).to receive(:merge_method).and_return('rebase')
      allow(subject).to receive(:pr_id).and_return(Faker::Number.number)
      expect(octokit_client_client).to receive(:merge_pull_request).and_return(double(sha: Faker::Internet.password))
      subject.merge
    end

    it 'should call various other methods' do
      expect(subject).to receive(:existing_pr).and_return(double(title: Faker::Lorem.word)).at_least(:once)
      expect(subject).to receive(:merge_method).and_return('rebase').at_least(:once)
      expect(subject).to receive(:pr_id).and_return(Faker::Number.number).at_least(:once)
      allow(octokit_client_client).to receive(:merge_pull_request).and_return(double(sha: Faker::Internet.password))
      subject.merge
    end

    it 'should catch the raised error if the merge does not work' do
      allow(subject).to receive(:existing_pr).and_return(double(title: Faker::Lorem.word))
      allow(subject).to receive(:merge_method).and_return('rebase')
      allow(subject).to receive(:pr_id).and_return(Faker::Number.number)
      allow(octokit_client_client).to receive(:merge_pull_request).and_raise(StandardError)
      expect(subject.merge).to eq(nil)
    end
  end

  describe '#new_pr_body' do
    it 'should call the local code if the template to apply exists' do
      allow(subject).to receive(:template_name_to_apply).and_return('')
      expect(local_code).to receive(:read_template)
      subject.send(:new_pr_body)
    end

    it 'should not call the local code if the template is nil' do
      allow(subject).to receive(:template_name_to_apply).and_return(nil)
      expect(local_code).not_to receive(:read_template)
      subject.send(:new_pr_body)
    end

    it 'should return an empty string if the template is nil' do
      allow(subject).to receive(:template_name_to_apply).and_return(nil)
      expect(subject.send(:new_pr_body)).to eq('')
    end
  end

  describe '#template_name_to_apply' do
    context 'if PR template options are empty' do
      it 'should return nil' do
        allow(subject).to receive(:pr_template_options).and_return([])
        expect(subject.send(:template_name_to_apply)).to eq(nil)
      end
    end

    context 'if there is one template option' do
      let(:template) { Faker::Lorem.word }

      it 'should call the CLI to ask about a single template' do
        allow(subject).to receive(:pr_template_options).and_return([template])
        expect(highline_cli).to receive(:apply_template?).and_return(true)
        subject.send(:template_name_to_apply)
      end

      it 'should return the single template if the user says yes' do
        allow(subject).to receive(:pr_template_options).and_return([template])
        allow(highline_cli).to receive(:apply_template?).and_return(true)
        expect(subject.send(:template_name_to_apply)).to eq(template)
      end

      it 'should return nil if the user says no' do
        allow(subject).to receive(:pr_template_options).and_return([template])
        allow(highline_cli).to receive(:apply_template?).and_return(false)
        expect(subject.send(:template_name_to_apply)).to eq(nil)
      end
    end

    context 'if there are multiple template options' do
      let(:template1) { Faker::Lorem.word }
      let(:template2) { Faker::Lorem.word }

      it 'should call the CLI to ask which of multiple templates to apply' do
        allow(subject).to receive(:pr_template_options).and_return([template1, template2])
        expect(highline_cli).to receive(:template_to_apply).and_return(template1)
        subject.send(:template_name_to_apply)
      end

      it 'should return the answer template if the user says yes' do
        allow(subject).to receive(:pr_template_options).and_return([template1, template2])
        allow(highline_cli).to receive(:template_to_apply).and_return(template1)
        expect(subject.send(:template_name_to_apply)).to eq(template1)
      end

      it 'should return nil if the user says no' do
        allow(subject).to receive(:pr_template_options).and_return([template1, template2])
        allow(highline_cli).to receive(:template_to_apply).and_return('None')
        expect(subject.send(:template_name_to_apply)).to eq(nil)
      end
    end
  end

  describe '#pr_template_options' do
    it 'should call the local code' do
      expect(local_code).to receive(:template_options)
      subject.send(:pr_template_options)
    end
  end

  describe '#pr_id' do
    it 'should ask the CLI for the code request ID' do
      expect(highline_cli).to receive(:code_request_id).and_return(Faker::Number.number)
      subject.send(:pr_id)
    end

    it 'should equal an integer' do
      pr_id = Faker::Number.number
      expect(highline_cli).to receive(:code_request_id).and_return(pr_id)
      expect(subject.send(:pr_id)).to eq(pr_id)
    end
  end

  describe '#merge_method' do
    let(:project) { double(:project, allow_merge_commit: true, allow_squash_merge: true, allow_rebase_merge: true) }

    before do
      allow(subject).to receive(:existing_project).and_return(project)
      allow(highline_cli).to receive(:merge_method)
    end

    it 'should ask the CLI for the merge_method' do
      expect(highline_cli).to receive(:merge_method).and_return('merge')
      subject.send(:merge_method)
    end

    it 'should be a string' do
      allow(highline_cli).to receive(:merge_method).and_return('merge')
      expect(subject.send(:merge_method)).to be_a(String)
    end

    context 'if theres only one item' do
      let(:project) { double(:project, allow_merge_commit: true, allow_squash_merge: false, allow_rebase_merge: false) }

      it 'should not ask the CLI anything' do
        expect(highline_cli).not_to receive(:merge_method)
        subject.send(:merge_method)
      end
    end
  end

  describe '#merge_options' do
    let(:project) { double(:project, allow_merge_commit: true, allow_squash_merge: true, allow_rebase_merge: true) }

    before do
      allow(subject).to receive(:existing_project).and_return(project)
    end

    it 'should return an array' do
      expect(subject.send(:merge_options)).to be_a(Array)
    end

    it 'should have three items' do
      expect(subject.send(:merge_options).length).to eq(3)
    end

    context 'when two options are present' do
      let(:project) { double(:project, allow_merge_commit: false, allow_squash_merge: true, allow_rebase_merge: true) }

      it 'should have two items' do
        expect(subject.send(:merge_options).length).to eq(2)
      end
    end

    context 'when one option is present' do
      let(:project) { double(:project, allow_merge_commit: false, allow_squash_merge: false, allow_rebase_merge: true) }

      it 'should have one item' do
        expect(subject.send(:merge_options).length).to eq(1)
      end
    end

    context 'when no options are present' do
      let(:project) { double(:project, allow_merge_commit: false, allow_squash_merge: false, allow_rebase_merge: false) }

      it 'should have no items' do
        expect(subject.send(:merge_options).length).to eq(0)
      end
    end
  end

  describe '#existing_project' do
    it 'should call the octokit client' do
      expect(octokit_client_client).to receive(:repository).and_return(:repository)
      subject.send(:existing_project)
    end
  end

  describe '#existing_pr' do
    it 'should call the octokit client' do
      allow(highline_cli).to receive(:code_request_id).and_return(Faker::Number.number)
      expect(octokit_client_client).to receive(:pull_request).and_return(:pull_request)
      subject.send(:existing_pr)
    end
  end

  describe '#octokit_client' do
    it 'should call the octokit client' do
      expect(GitHelper::OctokitClient).to receive(:new).and_return(octokit_client)
      subject.send(:octokit_client)
    end
  end
end
