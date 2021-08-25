RSpec.describe FlowStack do
  subject(:flow_stack) do
    described_class.new(
      service: service,
      previous: previous,
      current: current
    )
  end

  context 'flow object after a branch' do
    let(:metadata) { metadata_fixture(:branching) }
    let(:service) { MetadataPresenter::Service.new(metadata) }

    context 'multiple destinations' do
      let(:previous) do
        # branching point 2
        service.flow_object('ffadeb22-063b-4e4f-9502-bd753c706b1d')
      end
      let(:current) do
        # do you like apple juice?
        service.flow_object('d4342dfd-0d09-4a91-a0ea-d7fd67e706cc')
      end
      let(:first_group_uuids) do
        %w[d4342dfd-0d09-4a91-a0ea-d7fd67e706cc 91e9f7c6-2f75-4b7d-9eb5-0cf352f7be66]
      end
      let(:last_group_uuids) do
        %w[05c3306c-0a39-42d2-9e0f-93fd49248f4e]
      end

      it 'groups objects by their destinations' do
        grouped = flow_stack.grouped_flow_objects
        expect(grouped.count).to eq(2)
        expect(grouped.first.map(&:uuid)).to eq(first_group_uuids)
        expect(grouped.last.map(&:uuid)).to eq(last_group_uuids)
      end
    end

    context 'single destination' do
      let(:previous) do
        # branching point 7
        service.flow_object('1079b5b8-abd0-4bf6-aaac-1f01e69e3b39')
      end
      let(:current) do
        # you are wrong (GOTG)
        service.flow_object('6324cca4-7770-4765-89b9-1cdc41f49c8b')
      end
      let(:group_uuids) do
        %w[
          56e80942-d0a4-405a-85cd-bd1b100013d6
          6324cca4-7770-4765-89b9-1cdc41f49c8b
          941137d7-a1da-43fd-994a-98a4f9ea6d46
        ]
      end

      it 'groups objects by their destinations' do
        grouped = flow_stack.grouped_flow_objects
        expect(grouped.count).to eq(1)
        expect(grouped.first.map(&:uuid)).to eq(group_uuids)
      end
    end
  end

  context 'previous flow object is a page' do
    let(:previous) do
      # full name
      service.flow_object('9e1ba77f-f1e5-42f4-b090-437aa9af7f73')
    end
    let(:current) do
      # do you like star wars?
      service.flow_object('68fbb180-9a2a-48f6-9da6-545e28b8d35a')
    end

    it 'returns the current object' do
      expect(flow_stack.grouped_flow_objects).to eq([[current]])
    end
  end
end
