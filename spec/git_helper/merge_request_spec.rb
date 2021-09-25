# frozen_string_literal: true

require 'spec_helper'
require 'git_helper'

describe GitHelper::GitLabMergeRequest do
  let(:local_code) { double(:local_code, read_template: Faker::Lorem.word) }
  let(:highline_wrapper) { double(:highline_wrapper) }

  let(:gitlab_client) do
    double(:gitlab_client,
           create_merge_request: merge_request,
           accept_merge_request: merge_request)
  end

  let(:merge_request) do
    double(:merge_request,
           message: Faker::Lorem.sentence,
           diff_refs: { base_sha: Faker::Lorem.word, head_sha: Faker::Lorem.word },
           web_url: Faker::Internet.url,
           merge_commit_sha: Faker::Internet.password)
  end

  let(:options) do
    {
      local_project: Faker::Lorem.word,
      local_branch: Faker::Lorem.word,
      local_code: local_code,
      highline: highline_wrapper
    }
  end

  subject { described_class.new(options) }

  before do
    allow(GitHelper::GitLabClient).to receive(:new).and_return(gitlab_client)
    allow(subject).to receive(:puts)
  end

  describe '#create' do
    it 'should call the gitlab client to create' do
      allow(subject).to receive(:squash_merge_request).and_return(true)
      allow(subject).to receive(:remove_source_branch).and_return(false)
      allow(subject).to receive(:new_mr_body).and_return('')
      expect(gitlab_client).to receive(:create_merge_request).and_return(merge_request)
      subject.create({ base_branch: Faker::Lorem.word, new_title: Faker::Lorem.word })
    end

    it 'should call various other methods' do
      expect(subject).to receive(:squash_merge_request).and_return(true)
      expect(subject).to receive(:remove_source_branch).and_return(false)
      expect(subject).to receive(:new_mr_body).and_return('')
      allow(gitlab_client).to receive(:create_merge_request).and_return(merge_request)
      subject.create({ base_branch: Faker::Lorem.word, new_title: Faker::Lorem.word })
    end

    it 'should catch the raised error if the creation does not work' do
      allow(subject).to receive(:squash_merge_request).and_return(true)
      allow(subject).to receive(:remove_source_branch).and_return(false)
      allow(subject).to receive(:new_mr_body).and_return('')
      allow(gitlab_client).to receive(:create_merge_request).and_raise(StandardError)
      expect(subject.create({ base_branch: Faker::Lorem.word, new_title: Faker::Lorem.word })).to eq(nil)
    end
  end

  describe '#merge' do
    it 'should call the gitlab client to merge' do
      allow(subject).to receive(:existing_mr).and_return(double(should_remove_source_branch: true, squash: false, title: 'title'))
      allow(subject).to receive(:mr_id).and_return(Faker::Number.number)
      expect(gitlab_client).to receive(:accept_merge_request).and_return(merge_request)
      subject.merge
    end

    it 'should call various other methods' do
      expect(subject).to receive(:existing_mr).and_return(double(should_remove_source_branch: true, squash: false, title: 'title')).at_least(:once)
      expect(subject).to receive(:mr_id).and_return(Faker::Number.number).at_least(:once)
      allow(gitlab_client).to receive(:accept_merge_request).and_return(merge_request)
      subject.merge
    end

    it 'should catch the raised error if the merge does not work' do
      allow(subject).to receive(:existing_mr).and_return(double(should_remove_source_branch: true, squash: false, title: 'title'))
      allow(subject).to receive(:mr_id).and_return(Faker::Number.number)
      allow(gitlab_client).to receive(:accept_merge_request).and_raise(StandardError)
      expect(subject.merge).to eq(nil)
    end

    it 'should try to merge multiple times if the first merge errors' do
      allow(subject).to receive(:existing_mr).and_return(double(should_remove_source_branch: true, squash: false, title: 'title'))
      allow(subject).to receive(:mr_id).and_return(Faker::Number.number)
      expect(gitlab_client).to receive(:accept_merge_request).and_return(double(merge_commit_sha: nil, merge_error: Faker::Lorem.word, message: Faker::Lorem.sentence)).exactly(2).times
      expect(subject.merge).to eq(nil)
    end
  end

  describe '#new_mr_body' do
    it 'should call the local code if the template to apply exists' do
      allow(subject).to receive(:template_name_to_apply).and_return('')
      expect(local_code).to receive(:read_template)
      subject.send(:new_mr_body)
    end

    it 'should not call the local code if the template is nil' do
      allow(subject).to receive(:template_name_to_apply).and_return(nil)
      expect(local_code).not_to receive(:read_template)
      subject.send(:new_mr_body)
    end

    it 'should return an empty string if the template is nil' do
      allow(subject).to receive(:template_name_to_apply).and_return(nil)
      expect(subject.send(:new_mr_body)).to eq('')
    end
  end

  describe '#template_name_to_apply' do
    context 'if MR template options are empty' do
      it 'should return nil' do
        allow(subject).to receive(:mr_template_options).and_return([])
        expect(subject.send(:template_name_to_apply)).to eq(nil)
      end
    end

    context 'if there is one template option' do
      let(:template) { Faker::Lorem.word }

      it 'should call the CLI to ask about a single template' do
        allow(subject).to receive(:mr_template_options).and_return([template])
        expect(highline_wrapper).to receive(:ask_yes_no).and_return(true)
        subject.send(:template_name_to_apply)
      end

      it 'should return the single template if the user says yes' do
        allow(subject).to receive(:mr_template_options).and_return([template])
        allow(highline_wrapper).to receive(:ask_yes_no).and_return(true)
        expect(subject.send(:template_name_to_apply)).to eq(template)
      end

      it 'should return nil if the user says no' do
        allow(subject).to receive(:mr_template_options).and_return([template])
        allow(highline_wrapper).to receive(:ask_yes_no).and_return(false)
        expect(subject.send(:template_name_to_apply)).to eq(nil)
      end
    end

    context 'if there are multiple template options' do
      let(:template1) { Faker::Lorem.word }
      let(:template2) { Faker::Lorem.word }

      it 'should call the CLI to ask which of multiple templates to apply' do
        allow(subject).to receive(:mr_template_options).and_return([template1, template2])
        expect(highline_wrapper).to receive(:ask_options).and_return(template1)
        subject.send(:template_name_to_apply)
      end

      it 'should return the answer template if the user says yes' do
        allow(subject).to receive(:mr_template_options).and_return([template1, template2])
        allow(highline_wrapper).to receive(:ask_options).and_return(template1)
        expect(subject.send(:template_name_to_apply)).to eq(template1)
      end

      it 'should return nil if the user says no' do
        allow(subject).to receive(:mr_template_options).and_return([template1, template2])
        allow(highline_wrapper).to receive(:ask_options).and_return('None')
        expect(subject.send(:template_name_to_apply)).to eq(nil)
      end
    end
  end

  describe '#mr_template_options' do
    it 'should call the local code' do
      expect(local_code).to receive(:template_options)
      subject.send(:mr_template_options)
    end
  end

  describe '#mr_id' do
    it 'should ask the CLI for the code request ID' do
      expect(highline_wrapper).to receive(:ask).and_return(Faker::Number.number)
      subject.send(:mr_id)
    end

    it 'should equal an integer' do
      pr_id = Faker::Number.number
      expect(highline_wrapper).to receive(:ask).and_return(pr_id)
      expect(subject.send(:mr_id)).to eq(pr_id)
    end
  end

  describe '#squash_merge_request' do
    let(:existing_project) { double(squash_option: 'default_off') }

    it 'should return true if the squash is set to always on the project' do
      allow(subject).to receive(:existing_project).and_return(existing_project)
      allow(existing_project).to receive(:squash_option).and_return('always')
      expect(highline_wrapper).not_to receive(:ask_yes_no)
      expect(subject.send(:squash_merge_request)).to eq(true)
    end

    it 'should return true if the squash is set to default_on on the project' do
      allow(subject).to receive(:existing_project).and_return(existing_project)
      allow(existing_project).to receive(:squash_option).and_return('default_on')
      expect(highline_wrapper).not_to receive(:ask_yes_no)
      expect(subject.send(:squash_merge_request)).to eq(true)
    end

    it 'should return false if the squash is set to never on the project' do
      allow(subject).to receive(:existing_project).and_return(existing_project)
      allow(existing_project).to receive(:squash_option).and_return('never')
      expect(highline_wrapper).not_to receive(:ask_yes_no)
      expect(subject.send(:squash_merge_request)).to eq(false)
    end

    it 'should ask the user for their response to the squash question' do
      allow(subject).to receive(:existing_project).and_return(existing_project)
      allow(existing_project).to receive(:squash_option).and_return(nil)
      expect(highline_wrapper).to receive(:ask_yes_no).and_return(true)
      subject.send(:squash_merge_request)
    end

    it 'should be a boolean' do
      allow(subject).to receive(:existing_project).and_return(existing_project)
      allow(existing_project).to receive(:squash_option).and_return(nil)
      expect(highline_wrapper).to receive(:ask_yes_no).and_return(false)
      expect([true, false]).to include(subject.send(:squash_merge_request))
    end
  end

  describe '#remove_source_branch' do
    before do
      allow(subject).to receive(:existing_project).and_return(double(remove_source_branch_after_merge: nil))
    end

    context 'when the existing project has no setting' do
      it 'should ask the CLI for the code request ID' do
        expect(highline_wrapper).to receive(:ask_yes_no).and_return(true)
        subject.send(:remove_source_branch)
      end

      it 'should be a boolean' do
        allow(highline_wrapper).to receive(:ask_yes_no).and_return(false)
        expect([true, false]).to include(subject.send(:remove_source_branch))
      end
    end

    it 'should ask the existing project' do
      expect(subject).to receive(:existing_project).and_return(double(remove_source_branch_after_merge: true))
      subject.send(:remove_source_branch)
    end

    it 'should return the existing projects setting if it exists' do
      allow(subject).to receive(:existing_project).and_return(double(remove_source_branch_after_merge: true))
      expect(subject.send(:remove_source_branch)).to eq(true)
    end

    it 'should return the existing projects setting if it exists' do
      allow(subject).to receive(:existing_project).and_return(double(remove_source_branch_after_merge: false))
      allow(highline_wrapper).to receive(:ask_yes_no).and_return(true)
      expect(subject.send(:remove_source_branch)).to eq(true)
    end
  end

  describe '#existing_project' do
    it 'should call the gitlab client' do
      expect(gitlab_client).to receive(:project).and_return(:project)
      subject.send(:existing_project)
    end
  end

  describe '#existing_mr' do
    it 'should call the gitlab client' do
      allow(highline_wrapper).to receive(:ask).and_return(Faker::Number.number)
      expect(gitlab_client).to receive(:merge_request).and_return(:merge_request)
      subject.send(:existing_mr)
    end
  end

  describe '#gitlab_client' do
    it 'should call the gitlab client' do
      expect(GitHelper::GitLabClient).to receive(:new).and_return(gitlab_client)
      subject.send(:gitlab_client)
    end
  end
end
