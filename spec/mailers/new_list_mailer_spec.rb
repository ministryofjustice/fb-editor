require 'rails_helper'

RSpec.describe NewListMailer do
  before do
    allow(Rails.configuration).to receive(:govuk_notify_templates).and_return(
      new_ms_list_created: 'new_list_uuid'
    )
  end

  describe '#new_ms_list_created' do
    let(:user) { instance_double(User, email: 'test@example.com') }
    let(:form_name) { 'Test service' }
    let(:list_name) { 'Test Service - dev - uuid' }
    let(:drive_name) { 'Test Service - dev - uuid - attachments' }

    let(:mail) do
      described_class.new_ms_list_created(user:, form_name:, list_name:, drive_name:)
    end

    it_behaves_like 'a Notify mailer', template_id: 'new_list_uuid'

    it { expect(mail.to).to eq(['test@example.com']) }
    it { expect(mail.govuk_notify_personalisation[:form_name]).to eq(form_name) }
    it { expect(mail.govuk_notify_personalisation[:list_name]).to eq(list_name) }
    it { expect(mail.govuk_notify_personalisation[:drive_name]).to eq(drive_name) }
  end
end
