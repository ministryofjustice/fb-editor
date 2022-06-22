RSpec.describe 'Component validations spec', type: :request do
  let(:latest_metadata) { metadata_fixture(:version) }
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }
  let(:page_uuid) { '54ccc6cd-60c0-4749-947b-a97af1bc0aa2' } # your age
  let(:component_uuid) { 'b3014ef8-546a-4a35-9669-c5c1667e86d7' }

  before do
    allow_any_instance_of(
      Api::ComponentValidationsController
    ).to receive(:require_user!).and_return(true)

    allow_any_instance_of(
      Api::ComponentValidationsController
    ).to receive(:service).and_return(service)

    request
  end

  describe 'GET /api/services/:service_id/pages/:page_id/component-validations/:component/:validator' do
    let(:request) do
      get "/api/services/#{service.service_id}/pages/#{page_uuid}/component-validations/#{component_uuid}/minimum"
    end

    it 'returns 200' do
      expect(response.status).to be(200)
    end
  end

  describe 'POST /api/services/:service_id/pages/:page_id/component-validations/:component/:validator' do
    context 'when setting the component validation' do
      let(:request) do
        post "/api/services/#{service.service_id}/pages/#{page_uuid}/component-validations/#{component_uuid}/minimum",
             params: params
      end
      let(:params) do
        {
          component_validation: {
            status: 'enabled',
            value: '5'
          }
        }
      end

      it 'returns 202' do
        expect(response.status).to be(202)
      end
    end
  end
end
