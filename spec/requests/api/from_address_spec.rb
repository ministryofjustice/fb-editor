RSpec.describe 'From Address spec', type: :request do
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }
  let(:latest_metadata) { metadata_fixture(:version) }

  before do
    allow_any_instance_of(
      Api::FromAddressController
    ).to receive(:require_user!).and_return(true)

    allow_any_instance_of(
      Api::FromAddressController
    ).to receive(:service).and_return(service)

    allow_any_instance_of(
      FromAddressCreation
    ).to receive(:email_service).and_return(email_service)

    create(:from_address, :pending, service_id:, email:)
  end

  describe 'POST /api/services/:service_id/settings/from_address/resend' do
    let(:request) do
      post "/api/services/#{service_id}/settings/from_address/resend"
    end
    let(:email) { 'bob@digital.justice.gov.uk' }
    let(:service_id) { service.service_id }
    let(:email_service) { double }

    context 'context when resending validation' do
      before do
        allow(email_service).to receive(:create_email_identity)
      end

      it 'makes AWS call to delete identity' do
        expect(email_service).to receive(:delete_email_identity).with(email).and_return(double(successful?: true))

        request
      end
    end

    context 'when call to delete identity is successful' do
      before do
        allow(email_service).to receive(:delete_email_identity).with(email).and_return(double(successful?: true))
      end

      it 'makes create identity call' do
        expect(email_service).to receive(:create_email_identity).with(email)

        request
      end
    end

    context 'when call to delete identity is unsuccessful' do
      before do
        allow(email_service).to receive(:delete_email_identity).and_raise(EmailServiceError)

        request
      end
    end
  end
end
