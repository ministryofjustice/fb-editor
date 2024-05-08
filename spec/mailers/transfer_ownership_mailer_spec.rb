RSpec.describe TransferOwnershipMailer do
  before do
    allow(Rails.configuration).to receive(:govuk_notify_templates).and_return(
      transfer_ownership: 'transfer_ownership_uuid'
    )
  end

  let(:new_owner) { 'new_owner@example.com' }
  let(:service_name) { 'Test service' }
  let(:previous_owner) { 'previous_owner@example.com' }

  describe '#transfer_ownership' do
    let(:mail) do
      described_class.transfer_ownership(service_name:, previous_owner:, new_owner:)
    end

    before do
      allow(Rails.configuration).to receive(:govuk_notify_templates).and_return(
        transfer_ownership: 'transfer_ownership_uuid'
      )
    end

    it_behaves_like 'a Notify mailer', template_id: 'transfer_ownership_uuid'

    it { expect(mail.to).to eq(['new_owner@example.com']) }
    it { expect(mail.govuk_notify_personalisation[:service_name]).to eq(service_name) }
    it { expect(mail.govuk_notify_personalisation[:previous_owner]).to eq(previous_owner) }
  end

  describe '#transfer_ownership_confirmation' do
    let(:mail) do
      described_class.transfer_ownership_confirmation(service_name:, previous_owner:, new_owner:)
    end

    before do
      allow(Rails.configuration).to receive(:govuk_notify_templates).and_return(
        transfer_ownership_confirmation: 'transfer_ownership_confirmation_uuid'
      )
    end

    it_behaves_like 'a Notify mailer', template_id: 'transfer_ownership_confirmation_uuid'

    it { expect(mail.to).to eq(['previous_owner@example.com']) }
    it { expect(mail.govuk_notify_personalisation[:service_name]).to eq(service_name) }
    it { expect(mail.govuk_notify_personalisation[:new_owner]).to eq(new_owner) }
  end
end
