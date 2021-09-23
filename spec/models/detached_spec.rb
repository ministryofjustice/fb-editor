RSpec.describe Detached do
  subject(:detached) do
    described_class.new(
      service: service,
      ordered_flow: ordered_flow,
      exclude_branches: exclude_branches
    )
  end
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }
  let(:metadata) { metadata_fixture(:branching) }
  let(:checkanswers) do
    metadata['pages'].find { |p| p['_type'] == 'page.checkanswers' }
  end
  let(:exclude_branches) { false }
  let(:ordered_flow) do
    MetadataPresenter::Grid.new(service).ordered_flow
  end

  describe '#flow_objects' do
    context 'when there are detached flow objects' do
      let(:latest_metadata) do
        obj = metadata['flow']['48357db5-7c06-4e85-94b1-5e1c9d8f39eb'] # select all arnie quotes
        obj['next']['default'] = checkanswers['_uuid']
        metadata
      end

      context 'when exclude branches is false' do
        let(:expected_uuids) do
          [
            '1079b5b8-abd0-4bf6-aaac-1f01e69e3b39', # branching point 7
            '941137d7-a1da-43fd-994a-98a4f9ea6d46',
            '56e80942-d0a4-405a-85cd-bd1b100013d6',
            '6324cca4-7770-4765-89b9-1cdc41f49c8b'
          ]
        end

        it 'returns an array of detached objects' do
          expect(detached.flow_objects.map(&:uuid)).to eq(expected_uuids)
        end
      end

      context 'exclude branches is true' do
        let(:exclude_branches) { true }
        let(:ordered_flow) do
          MetadataPresenter::Grid.new(service).ordered_pages
        end
        let(:expected_uuids) do
          %w[
            941137d7-a1da-43fd-994a-98a4f9ea6d46
            56e80942-d0a4-405a-85cd-bd1b100013d6
            6324cca4-7770-4765-89b9-1cdc41f49c8b
          ]
        end

        it 'returns an array of detached objects excluding branches' do
          expect(detached.flow_objects.map(&:uuid)).to eq(expected_uuids)
        end
      end
    end

    context 'when there are no detached flow objects' do
      let(:latest_metadata) { metadata }

      it 'should not return any detached objects' do
        expect(detached.flow_objects.map(&:uuid)).to be_empty
      end
    end
  end
end
