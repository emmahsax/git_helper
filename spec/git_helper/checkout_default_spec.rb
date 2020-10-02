require_relative '../../lib/git_helper/checkout_default.rb'

describe GitHelper::CheckoutDefault do
  let(:local_code) { double(:local_code, checkout_default: :done) }

  subject { GitHelper::CheckoutDefault.new }

  it 'should call GitHelper::LocalCode' do
    expect(GitHelper::LocalCode).to receive(:new).and_return(local_code)
    subject.execute
  end

  it 'should call the checkout_default method from the local code class' do
    allow(GitHelper::LocalCode).to receive(:new).and_return(local_code)
    expect(local_code).to receive(:checkout_default)
    subject.execute
  end
end
