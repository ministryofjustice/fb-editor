RSpec.describe Destination do
  subject(:destination) do
    described_class.new(
      service: service,
      flow_uuid: flow_uuid,
      destination_uuid: destination_uuid
    )
  end

  describe '#change' do
    context 'when changing the flow object destination' do
      let(:flow_uuid) { '9e1ba77f-f1e5-42f4-b090-437aa9af7f73' }
      let(:destination_uuid) { 'e337070b-f636-49a3-a65c-f506675265f0' }
      let(:version) { double(errors?: false, errors: [], metadata: updated_metadata) }
      let(:updated_metadata) do
        metadata = service_metadata.deep_dup
        metadata['flow'][flow_uuid]['next']['default'] = destination_uuid
        metadata
      end

      before do
        expect(
          MetadataApiClient::Version
        ).to receive(:create).with(
          service_id: service.service_id,
          payload: updated_metadata
        ).and_return(version)
      end

      it 'correctly updates the default next' do
        updated_flow = destination.change['flow'][flow_uuid]
        expect(updated_flow['next']['default']).to eq(destination_uuid)
      end
    end
  end
end
