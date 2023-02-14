RSpec.describe NewFlowPageGenerator do
  subject(:generator) do
    described_class.new(
      page_uuid:,
      default_next:,
      latest_metadata:
    )
  end
  let(:page_uuid) { SecureRandom.uuid }
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
        let(:default_next) { 'some-uuid' }
        let(:expected_metadata) do
          {
            page_uuid => {
              '_type' => 'flow.page',
              'next' => {
                'default' => default_next
              }
            }
          }
        end
      end
    end

    context 'when there is no next page' do
      it_behaves_like 'a flow page generator' do
        let(:default_next) { nil }
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
