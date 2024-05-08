RSpec.describe TransferOwnershipMailer do
  before do
    allow(Rails.configuration).to receive(:govuk_notify_templates).and_return(
      transfer_ownership: 'transfer_ownership_uuid'
    )
  end

  describe '#transfer_ownership' do
    let(:new_owner) { 'new_owner@example.com' }
    let(:service_name) { 'Test service' }
    let(:previous_owner) { 'previous_owner@example.com' }

    let(:mail) do
      described_class.transfer_ownership(service_name:, previous_owner:, new_owner:)
    end

    it_behaves_like 'a Notify mailer', template_id: 'transfer_ownership_uuid'

    it { expect(mail.to).to eq(['new_owner@example.com']) }
    it { expect(mail.govuk_notify_personalisation[:service_name]).to eq(service_name) }
    it { expect(mail.govuk_notify_personalisation[:previous_owner]).to eq(previous_owner) }
  end
end
