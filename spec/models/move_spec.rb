RSpec.describe Move do
  subject(:move) do
    described_class.new(
      service: service,
      grid: grid,
      previous_flow_uuid: previous_flow_uuid,
      to_move_uuid: to_move_uuid,
      target_uuid: target_uuid,
      conditional_uuid: conditional_uuid
    )
  end
  let(:latest_metadata) { metadata_fixture(:branching_11) }
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }
  let(:grid) { MetadataPresenter::Grid.new(service) }
  let(:previous_flow_uuid) { nil }
  let(:to_move_uuid) { nil }
  let(:target_uuid) { nil }
  let(:conditional_uuid) { nil }

  describe '#targets' do
    let(:to_move_uuid) { '2ffc17b7-b14a-417f-baff-07adebd4f259' } # Page B
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
end
