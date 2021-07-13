RSpec.describe NewFlowPageGenerator do
  subject(:generator) do
    described_class.new(
      page_uuid: page_uuid,
      page_index: page_index,
      latest_metadata: latest_metadata
    )
  end
  let(:latest_metadata) { metadata_fixture('branching') }
  let(:valid) { true }

  describe '#to_metadata' do
    shared_examples 'a flow page generator' do
      it 'creates valid base flow object metadata' do
        expect(
          MetadataPresenter::ValidateSchema.validate(
            generator.to_metadata, 'flow.base'
          )
        ).to be(valid)
      end

      it 'creates valid flow page object metadata' do
        expect(
          MetadataPresenter::ValidateSchema.validate(
            generator.to_metadata[page_uuid], 'flow.page'
          )
        ).to be(valid)
      end

      it 'creates the correct metadata with the next page uuid' do
        expect(generator.to_metadata).to eq(expected_metadata)
      end
    end

    context 'when there is a next page' do
      it_behaves_like 'a flow page generator' do
        let(:page_uuid) { latest_metadata['pages'][0]['_uuid'] }
        let(:page_index) { 0 }
        let(:expected_metadata) do
          {
            page_uuid => {
              '_type' => 'flow.page',
              'next' => {
                'default' => latest_metadata['pages'][1]['_uuid']
              }
            }
          }
        end
      end
    end

    context 'when there is no next page' do
      it_behaves_like 'a flow page generator' do
        let(:page_uuid) { latest_metadata['pages'].last['_uuid'] }
        let(:page_index) { nil }
        let(:expected_metadata) do
          {
            page_uuid => {
              '_type' => 'flow.page',
              'next' => {
                'default' => ''
              }
            }
          }
        end
      end
    end
  end
end
