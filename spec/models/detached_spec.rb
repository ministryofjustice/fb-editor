RSpec.describe Detached do
  subject(:detached) do
    described_class.new(
      service:,
      main_flow_uuids:,
      exclude_branches:
    )
  end
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }
  let(:metadata) { metadata_fixture(:branching) }
  let(:checkanswers) do
    metadata['pages'].find { |p| p['_type'] == 'page.checkanswers' }
  end
  let(:exclude_branches) { false }
  let(:main_flow_uuids) { MetadataPresenter::Grid.new(service).flow_uuids }

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

  describe '#detached_flows' do
    context 'detaching a branch - branching fixture' do
      let(:latest_metadata) do
        meta = metadata_fixture(:branching)
        # select all arnie quotes
        meta['flow']['48357db5-7c06-4e85-94b1-5e1c9d8f39eb']['next']['default'] = check_answers_uuid
        meta
      end
      let(:check_answers_uuid) { 'e337070b-f636-49a3-a65c-f506675265f0' }
      let(:expected_detached_flows) do
        [
          [
            [
              service.flow_object('1079b5b8-abd0-4bf6-aaac-1f01e69e3b39') # Branching point 7
            ],
            [
              service.flow_object('941137d7-a1da-43fd-994a-98a4f9ea6d46'), # You are right
              service.flow_object('56e80942-d0a4-405a-85cd-bd1b100013d6'), # You are wrong
              MetadataPresenter::Spacer.new,
              service.flow_object('6324cca4-7770-4765-89b9-1cdc41f49c8b') # You are wrong (incomplete)
            ],
            [
              MetadataPresenter::Pointer.new(uuid: check_answers_uuid) # Check answers
            ]
          ]
        ]
      end

      it 'returns an array of flows with pointers' do
        expect(detached.detached_flows).to eq(expected_detached_flows)
      end
    end

    context 'multiple detached flows - branching fixture 2' do
      let(:latest_metadata) do
        meta = metadata_fixture(:branching_2)
        obj = meta['flow']['09e91fd9-7a46-4840-adbc-244d545cfef7'] # Branching Point 1
        # Detach Page G
        obj['next']['conditionals'] = [obj['next']['conditionals'].shift]
        # Detach Page J
        obj['next']['default'] = 'e337070b-f636-49a3-a65c-f506675265f0' # Check answers
        meta['flow']['09e91fd9-7a46-4840-adbc-244d545cfef7'] = obj
        meta
      end
      let(:check_answers_uuid) { 'e337070b-f636-49a3-a65c-f506675265f0' }
      let(:expected_detached_flows) do
        [
          [
            [
              service.flow_object('f475d6fd-0ea4-45d5-985e-e1a7c7a5b992') # Page J
            ],
            [
              service.flow_object('d80a2225-63c3-4944-873f-504b61311a15') # Branching Point 2
            ],
            [
              service.flow_object('be130ac1-f33d-4845-807d-89b23b90d205'), # Page K
              service.flow_object('d80a2225-63c3-4944-873f-504b61311a15') # Page M
            ],
            [
              service.flow_object('2c7deb33-19eb-4569-86d6-462e3d828d87'), # Page L
              service.flow_object('393645a4-f037-4e75-8359-51f9b0e360fb') # Page N
            ],
            [
              MetadataPresenter::Pointer.new(uuid: check_answers_uuid) # Check answers
            ]
          ],
          [
            [
              service.flow_object('3a584d15-6805-4a21-bc05-b61c3be47857') # Page G
            ],
            [
              service.flow_object('7a561e9f-f4f8-4d2e-a01e-4097fc3ccf1c') # Page H
            ],
            [
              service.flow_object('520fde26-8124-4c67-a550-cd38d2ef304d') # Page I
            ],
            [
              MetadataPresenter::Pointer.new(uuid: check_answers_uuid) # Check answers
            ]
          ]
        ]
      end

      it 'returns an array of flows with pointers' do
        expect(detached.detached_flows).to eq(expected_detached_flows)
      end
    end
  end
end
