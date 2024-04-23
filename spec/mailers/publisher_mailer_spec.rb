require 'rails_helper'

RSpec.describe PublisherMailer do
  before do
    allow(Rails.configuration).to receive(:govuk_notify_templates).and_return(
      first_time_publish_to_test: 'first_time_publish_to_test_uuid'
    )
  end

  describe '#first_time_publish_to_test' do
    let(:user) { instance_double(User, email: 'test@example.com') }
    let(:form_name) { 'Test service' }
    let(:form_url) { 'https://form.example.com' }

    let(:mail) do
      described_class.first_time_publish_to_test(user:, form_name:, form_url:)
    end

    it_behaves_like 'a Notify mailer', template_id: 'first_time_publish_to_test_uuid'

    it { expect(mail.to).to eq(['test@example.com']) }
    it { expect(mail.govuk_notify_personalisation[:form_name]).to eq(form_name) }
    it { expect(mail.govuk_notify_personalisation[:form_url]).to eq(form_url) }
  end
end
