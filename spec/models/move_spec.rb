RSpec.describe Move do
  subject(:move) do
    described_class.new(
      service:,
      grid:,
      previous_flow_uuid:,
      previous_conditional_uuid:,
      to_move_uuid:,
      target_uuid:,
      target_conditional_uuid:
    )
  end
  let(:latest_metadata) { metadata_fixture(:branching_11) }
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }
  let(:grid) { MetadataPresenter::Grid.new(service) }
  let(:previous_flow_uuid) { nil }
  let(:previous_conditional_uuid) { nil }
  let(:to_move_uuid) { nil }
  let(:target_uuid) { nil }
  let(:target_conditional_uuid) { nil }

  describe '#to_partial_path' do
    let(:latest_metadata) { metadata_fixture(:branching_2) }

    context 'when moving the page would cause branches to stack' do
      let(:to_move_uuid) { 'f475d6fd-0ea4-45d5-985e-e1a7c7a5b992' } # Page J
      let(:previous_flow_uuid) { '09e91fd9-7a46-4840-adbc-244d545cfef7' } # Branching Point 1
      let(:expected_partial_path) { 'stacked_branches_not_supported' }

      it 'returns the stacked branches not supported partial' do
        expect(move.to_partial_path).to eq(expected_partial_path)
      end
    end

    context 'when moving a page would not cause stacked branches' do
      let(:to_move_uuid) { 'cf6dc32f-502c-4215-8c27-1151a45735bb' } # Page B
      let(:previous_flow_uuid) { service.start_page.uuid }
      let(:expected_partial_path) { 'new' }

      it 'returns the default new partial' do
        expect(move.to_partial_path).to eq(expected_partial_path)
      end
    end

    context 'when there is no previous object uuid' do
      let(:to_move_uuid) { 'cf6dc32f-502c-4215-8c27-1151a45735bb' } # Page B
      let(:expected_partial_path) { 'new' }

      it 'returns the default new partial' do
        expect(move.to_partial_path).to eq(expected_partial_path)
      end
    end

    context 'move a branch destination that has no default next' do
      let(:latest_metadata) { metadata_fixture(:branching_7) }
      let(:metadata_flow) { move.metadata['flow'] }
      let(:to_move_uuid) { '3a584d15-6805-4a21-bc05-b61c3be47857' } # Page G
      let(:previous_flow_uuid) { 'ffadeb22-063b-4e4f-9502-bd753c706b1d' } # Branching Point 2
      let(:expected_partial_path) { 'branch_destination_no_default_next' }

      it 'returns the branch destination no default next partial' do
        expect(move.to_partial_path).to eq(expected_partial_path)
      end
    end

    context 'when the object to move default next is empty' do
      let(:latest_metadata) do
        meta = metadata_fixture(:branching_2)
        meta['flow'][to_move_uuid]['next']['default'] = ''
        meta
      end
      let(:to_move_uuid) { '65a2e01a-57dc-4702-8e41-ed8f9921ac7d' } # Page D
      let(:previous_flow_uuid) { 'fda1e5a1-ed5f-49c9-a943-dc930a520984' } # Page C
      let(:expected_partial_path) { 'new' }

      it 'returns the default new partial' do
        expect(move.to_partial_path).to eq(expected_partial_path)
      end
    end
  end

  describe '#targets' do
    let(:to_move_uuid) { '2ffc17b7-b14a-417f-baff-07adebd4f259' } # Page B
    let(:previous_flow_uuid) { '1d60bef0-100a-4f3b-9e6f-1711e8adda7e' } # Page A
    let(:targets) { move.targets }
    let(:target_uuids) { targets.map { |t| t[:target_uuid] } }
    let(:target_titles) { targets.map { |t| t[:title] } }
    let(:unconnected_uuids) { service.flow.keys - grid.flow_uuids }
    let(:expected_target_titles) do
      [
        'Service name goes here',
        'Page A',
        'Branching point 1 (Branch 1)',
        'Branching point 1 (Branch 2)',
        'Branching point 1 (Branch 3)',
        'Page C',
        'Page D',
        'Page E',
        'Page F',
        'Branching point 4 (Branch 1)',
        'Branching point 4 (Branch 2)',
        'Branching point 4 (Branch 3)',
        'Branching point 4 (Branch 4)',
        'Branching point 4 (Branch 5)',
        'Page G',
        'Page H',
        'Page I',
        'Page J',
        'Branching point 2 (Branch 1)',
        'Branching point 2 (Branch 2)',
        'Branching point 2 (Branch 3)',
        'Page K',
        'Page L',
        'Page M',
        'Page N',
        'Page O',
        'Branching point 3 (Branch 1)',
        'Branching point 3 (Branch 2)',
        'Page P'
      ]
    end

    it 'lists the targets in order of rows with branch destinations listed together' do
      expect(target_titles).to eq(expected_target_titles)
    end

    it 'does not include the object being moved' do
      expect(target_uuids).not_to include(to_move_uuid)
    end

    it 'sets the correct uuid for an object' do
      expect(targets.first[:target_uuid]).to eq(service.start_page.uuid)
    end

    it 'does not include any unconnected pages' do
      expect(target_uuids).not_to include(*unconnected_uuids)
    end

    context 'selected property' do
      let(:previous_flow_target) do
        targets.find { |t| t[:target_uuid] == previous_flow_uuid }
      end
      let(:other_targets) do
        targets.reject { |t| t[:target_uuid] == previous_flow_uuid }
      end

      it 'sets the selected property when previous page matches to true' do
        expect(previous_flow_target[:selected]).to be_truthy
      end

      it 'sets the selected property to false when previous page has not been matched' do
        other_targets.each do |target|
          expect(target[:selected]).to be_falsey
        end
      end
    end

    context 'page targets' do
      let(:page_targets) do
        targets.reject { |t| service.flow_object(t[:target_uuid]).branch? }
      end
      let(:target_uuids) { page_targets.map { |t| t[:target_uuid] } }

      it 'does not show the checkanswers page' do
        expect(target_uuids).not_to include(service.checkanswers_page.uuid)
      end

      it 'does not show the confirmation page' do
        expect(target_uuids).not_to include(service.confirmation_page.uuid)
      end

      context 'exit pages' do
        let(:latest_metadata) { metadata_fixture(:exit_only_service) }
        let(:exit_page_uuid) do
          service.pages.find { |p| p.type == 'page.exit' }.uuid
        end

        it 'does not show any exit pages' do
          expect(target_uuids).not_to include(exit_page_uuid)
        end
      end
    end

    context 'branch targets' do
      let(:branch_targets) do
        targets.select { |t| service.flow_object(t[:target_uuid]).branch? }
      end
      let(:target_uuids) { branch_targets.map { |t| t[:target_uuid] } }
      let(:branch) { service.flow_object('f55d002d-b2c1-4dcc-87b7-0da7cbc5c87c') } # branching point 1
      let(:conditional) { branch.conditionals[1] }

      it 'sets the branch uuid' do
        expect(branch_targets[1][:target_uuid]).to eq(branch.uuid)
      end

      it 'sets the conditional uuid' do
        expect(branch_targets[1][:conditional_uuid]).to eq(conditional.uuid)
      end
    end
  end

  describe '#metadata' do
    context 'updating previous object metadata' do
      before do
        allow(move).to receive(:update_page).and_return({})
        allow(move).to receive(:update_branch).and_return({})
      end

      context 'no previous flow uuid' do
        let(:to_move_uuid) { service.start_page.uuid }

        it 'does not try to update a previous flow object' do
          expect(move).not_to receive(:update_previous_flow_object)
          move.metadata
        end
      end

      context 'previous flow uuid present' do
        let(:metadata_flow) { move.metadata['flow'] }

        context 'previous flow uuid is a page' do
          let(:to_move_uuid) { '2ffc17b7-b14a-417f-baff-07adebd4f259' } # Page B
          let(:previous_flow_uuid) { '1d60bef0-100a-4f3b-9e6f-1711e8adda7e' } # Page A
          let(:expected_default_next) { 'f55d002d-b2c1-4dcc-87b7-0da7cbc5c87c' } # Branching Point 1

          it 'updates the previous default next to the to_move objects original default next' do
            expect(metadata_flow[previous_flow_uuid]['next']['default']).to eq(expected_default_next)
          end
        end

        context 'previous flow uuid id a branch' do
          context 'when previous conditional uuid is present' do
            let(:previous_flow_uuid) { 'f55d002d-b2c1-4dcc-87b7-0da7cbc5c87c' } # Branching Point 1
            let(:to_move_uuid) { '66c9e581-942e-4a9e-93ec-343208a2f510' } # Page C
            let(:previous_conditional_uuid) { '9149bc4c-9773-454f-b9b6-5524b91102ca' }
            let(:expected_default_next) { 'e31718ad-0ba7-4b45-81aa-d3081f423022' } # Page D

            it 'updates the conditional next to the to_move objects original default next' do
              conditional = metadata_flow[previous_flow_uuid]['next']['conditionals'].find do |c|
                c['_uuid'] == previous_conditional_uuid
              end
              expect(conditional['next']).to eq(expected_default_next)
            end
          end

          context 'when previous conditional uuid is not present' do
            let(:latest_metadata) { metadata_fixture(:branching_10) }
            let(:previous_flow_uuid) { 'f55d002d-b2c1-4dcc-87b7-0da7cbc5c87c' } # Branching Point 1
            let(:to_move_uuid) { 'ad011e6b-5926-42f8-8b7c-668558850c52' } # Page N
            let(:expected_default_next) { '957f9475-6341-418d-a554-d00c5700e031' } # Page O

            it 'updates the branch default next to the to_move objects original default next' do
              expect(metadata_flow[previous_flow_uuid]['next']['default']).to eq(expected_default_next)
            end
          end
        end
      end

      context 'moving an exit page' do
        let(:latest_metadata) { metadata_fixture(:branching_7) }
        let(:metadata_flow) { move.metadata['flow'] }
        let(:to_move_uuid) { '3a584d15-6805-4a21-bc05-b61c3be47857' } # Page G
        let(:previous_flow_uuid) { 'ffadeb22-063b-4e4f-9502-bd753c706b1d' } # Branching Point 2
        let(:target_uuid) { '13ecf9bd-5064-4cad-baf8-3dfa091928cb' } # Page F

        it 'does not update the exit pages default next' do
          expect(metadata_flow[to_move_uuid]['next']['default']).to be_empty
        end
      end
    end

    context 'upating target object metadata' do
      let(:metadata_flow) { move.metadata['flow'] }
      let(:to_move_uuid) { '2ffc17b7-b14a-417f-baff-07adebd4f259' } # Page B
      let(:previous_flow_uuid) { '1d60bef0-100a-4f3b-9e6f-1711e8adda7e' } # Page A

      context 'moving after a page' do
        let(:target_uuid) { '007f4f35-8236-40cc-866c-cc2c27c33949' } # Page E
        let(:page_f) { '7742dfcc-db2e-480b-9071-294fbe1769a2' }

        it 'updates to the target_uuid default next to the to_move_uuid' do
          expect(metadata_flow[target_uuid]['next']['default']).to eq(to_move_uuid)
        end

        it 'sets the to_move_uuid default next to be the target objects original default next' do
          expect(metadata_flow[to_move_uuid]['next']['default']).to eq(page_f)
        end
      end

      context 'replacing a branch destination' do
        let(:target_uuid) { 'a02f7073-ba5a-459d-b6b9-abe548c933a6' } # Branching Point 2

        context 'conditional destination' do
          let(:target_conditional_uuid) { '4ad9f7e9-5444-41d8-b7f8-17d2108ed27a' }
          let(:checkanswers) { 'da2576f9-7ddd-4316-b24b-103708139214' }

          it 'updates the branch condtional next to the to_move_uuid' do
            conditional = metadata_flow[target_uuid]['next']['conditionals'].find do |c|
              c['_uuid'] == target_conditional_uuid
            end
            expect(conditional['next']).to eq(to_move_uuid)
          end

          it 'sets the to_move objects default next to the conditional objects original destination' do
            expect(metadata_flow[to_move_uuid]['next']['default']).to eq(checkanswers)
          end
        end

        context 'branch default next destination' do
          let(:page_f) { '7742dfcc-db2e-480b-9071-294fbe1769a2' }

          it 'sets the branch defult next to the to move objects uuid' do
            expect(metadata_flow[target_uuid]['next']['default']).to eq(to_move_uuid)
          end

          it 'sets the to_move objects default next to the conditional objects original destination' do
            expect(metadata_flow[to_move_uuid]['next']['default']).to eq(page_f)
          end
        end
      end

      context 'when moving a page would result in it pointing to itself' do
        let(:latest_metadata) { metadata_fixture(:branching_11) }
        let(:metadata_flow) { move.metadata['flow'] }
        let(:to_move_uuid) { 'e31718ad-0ba7-4b45-81aa-d3081f423022' } # Page D
        let(:previous_flow_uuid) { '66c9e581-942e-4a9e-93ec-343208a2f510' } # Page C
        let(:target_uuid) { 'f55d002d-b2c1-4dcc-87b7-0da7cbc5c87c' } # Branching Point 1
        let(:page_e) { '007f4f35-8236-40cc-866c-cc2c27c33949' }

        it 'does not update the default next of the page being moved' do
          expect(metadata_flow[to_move_uuid]['next']['default']).to eq(page_e)
        end
      end
    end
  end
end
