RSpec.describe 'Branch' do
  describe 'GET /api/services/:service_id/branches/:branch_previous_flow_uuid/conditionals/:conditional_index' do
    let(:request) do
      get "/api/services/#{service.service_id}/branches/#{previous_flow_uuid}/conditionals/#{conditional_index}"
    end
    let(:previous_flow_uuid) { '68fbb180-9a2a-48f6-9da6-545e28b8d35a' }

    before do
      allow_any_instance_of(
        Api::BranchesController
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
          'select name="branch[conditionals_attributes][2][next]"'
        )
      end
    end

    context 'when there are more than one conditional' do
      let(:conditional_index) { 2 }

      it 'returns the next conditional' do
        expect(response.body).to include(
          'select name="branch[conditionals_attributes][3][next]"'
        )
      end
    end
  end
end
