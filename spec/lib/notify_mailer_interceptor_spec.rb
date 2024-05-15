require 'rails_helper'

describe NotifyMailerInterceptor do
  let(:message) do
    Mail::Message.new(
      from: ['from@example.com'],
      to: [recipient_email]
    )
  end

  before do
    described_class.delivering_email(message)
  end

  context 'when the email recipient is the acceptance tests user' do
    let(:recipient_email) { 'fb-acceptance-tests@digital.justice.gov.uk' }

    it 'does not perform deliveries' do
      expect(message.perform_deliveries).to be(false)
    end
  end

  context 'when the email recipient is not the acceptance tests user' do
    let(:recipient_email) { 'john@example.com' }

    it 'performs deliveries' do
      expect(message.perform_deliveries).to be(true)
    end
  end
end
