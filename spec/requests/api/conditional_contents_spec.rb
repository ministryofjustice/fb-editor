RSpec.describe 'ConditionalContents' do
  describe 'GET /api/services/:service_id/conditional-contents/:component_id/conditionals/:conditional_index' do
    let(:request) do
      get "/api/services/#{service.service_id}/conditional-contents/#{component_id}/conditionals/#{conditional_index}"
    end
    let(:previous_flow_uuid) { 'c7755991-436b-4495-afa6-803db58cefbc' } # page before CYA
    let(:component_id) { 'b065ff4f-90c5-4ba2-b4ac-c984a9dd2470' }

    before do
      allow_any_instance_of(
        Api::ConditionalContentsController
      ).to receive(:require_user!).and_return(true)
      allow(MetadataApiClient::Service).to receive(:latest_version).with(
        service.service_id
      )
        .and_return(
          metadata_fixture(:version)
        )

      request
    end

    context 'when there is one conditional' do
      let(:conditional_index) { 1 }

      it 'returns the next conditional' do
        expect(response.body).to include(
          'name="conditional-content[conditionals_attributes][2]"'
        )
      end
    end
  end
end
