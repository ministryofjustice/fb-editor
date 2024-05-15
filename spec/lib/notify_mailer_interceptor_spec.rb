require 'rails_helper'

describe NotifyMailerInterceptor do
  let(:message) do
    Mail::Message.new(
      from: ['from@example.com'],
      to: ['to@example.com']
    )
  end

  before do
    allow(ENV).to receive(:[]).with('ACCEPTANCE_TESTS_USER').and_return(tests_user_email)
    described_class.delivering_email(message)
  end

  context 'when the email recipient matches the acceptance tests user' do
    let(:tests_user_email) { 'to@example.com' }

    it 'does not perform deliveries' do
      expect(message.perform_deliveries).to be(false)
    end
  end

  context 'when the email recipient is not the acceptance tests user' do
    let(:tests_user_email) { 'john@example.com' }

    it 'performs deliveries' do
      expect(message.perform_deliveries).to be(true)
    end
  end
end
