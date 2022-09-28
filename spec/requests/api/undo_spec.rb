RSpec.describe 'Undo spec', type: :request do
  describe 'GET /api/services/:service_id/versions/previous' do
    let(:service_id) { SecureRandom.uuid }
    let(:url) { "/api/services/#{service.service_id}/versions/previous" }
    let(:request) { get url }
    let(:expected_body) do
      {
        "_id": 'service.base',
        "_type": 'service.base'
      }
    end
    let(:mock_response_previous) { double('response', metadata: expected_body) }

    before do
      allow_any_instance_of(
        Api::UndoController
      ).to receive(:require_user!).and_return(true)

      allow_any_instance_of(
        Api::UndoController
      ).to receive(:service).and_return(service)
      allow(mock_response_previous).to receive(:errors?).and_return(false)
    end

    context 'connecting to metadata api correctly' do
      context 'get the page correctly' do
        before do
          allow(
            MetadataApiClient::Version
          ).to receive(:previous).and_return(mock_response_previous)
          allow(
            MetadataApiClient::Version
          ).to receive(:create).and_return(double(errors?: false))
          request
        end

        it 'redirect to the previous page' do
          expect(response).to redirect_to(edit_service_path(service.service_id))
        end

        it 'returns 302' do
          expect(response.status).to eq(302)
        end
      end
    end

    context 'there is an error returned by the metadata API' do
      let(:api_response) { MetadataApiClient::ErrorMessages.new(['no no no']) }

      context 'call to version.previous fails' do
        before do
          allow(MetadataApiClient::Version).to receive(:previous).and_return(api_response)
        end

        it 'doesn\'t call version create' do
          request
          expect(MetadataApiClient::Version).not_to receive(:create)
        end
      end

      context 'call to version.create fails' do
        before do
          allow(
            MetadataApiClient::Version
          ).to receive(:previous).and_return(mock_response_previous)

          allow(MetadataApiClient::Version).to receive(:create).and_return(api_response)
          request
        end
        it 'doesn\'t redirect' do
          expect(response).to_not redirect_to(edit_service_path(service.service_id))
        end
      end
    end
  end

  describe 'GET services/:id/edit' do
    let(:service_id) { SecureRandom.uuid }
    let(:request) { get "/services/#{service_id}/edit" }

    before do
      allow_any_instance_of(
        Api::UndoController
      ).to receive(:require_user!).and_return(true)

      allow_any_instance_of(
        Api::UndoController
      ).to receive(:service).and_return(service)

      allow_any_instance_of(ServicesController).to receive(:session).and_return(session_hash)

      request
    end

    context 'when an undo property is present in global variable session' do
      let(:session_hash) { { undo: 'next page' } }

      it 'session key undo is deleted when service controller is called' do
        expect(session.key?(:undo)).to be_falsey
      end
    end
  end
end
