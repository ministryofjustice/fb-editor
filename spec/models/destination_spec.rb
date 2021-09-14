RSpec.describe Destination do
  subject(:destination) do
    described_class.new(
      service: service,
      flow_uuid: flow_uuid,
      destination_uuid: destination_uuid
    )
  end
  let(:latest_metadata) { metadata_fixture('branching') }
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }
  let(:flow_uuid) { '9e1ba77f-f1e5-42f4-b090-437aa9af7f73' } # Full name
  let(:destination_uuid) { 'e337070b-f636-49a3-a65c-f506675265f0' }

  describe '#change' do
    context 'when changing the flow object destination' do
      let(:version) { double(errors?: false, errors: [], metadata: updated_metadata) }
      let(:updated_metadata) do
        metadata = latest_metadata.deep_dup
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

  describe '#destinations' do
    context 'when listing all the destinations' do
      let(:expected_destinations) do
        [
          'Do you like Star Wars?',
          'Branching point 1',
          'How well do you know Star Wars?',
          'What is your favourite fruit?',
          'Branching point 2',
          'Do you like apple juice?',
          'Do you like orange juice?',
          'What is your favourite band?',
          'Branching point 3',
          'Which app do you use to listen music?',
          'What is the best form builder?',
          'Branching point 4',
          'Which Formbuilder is the best?',
          'What would you like on your burger?',
          'Branching point 5',
          'Global warming',
          'We love chickens',
          'What is the best marvel series?',
          'Branching point 6',
          'Loki',
          'Other quotes',
          'Select all Arnold Schwarzenegger quotes',
          'Branching point 7',
          'You are right',
          'You are wrong',
          'You are wrong',
          'Check your answers'
        ]
      end

      it 'returns branches and pages in flow order without start, confirmation and the page that is being changed' do
        destinations = destination.destinations.map { |d| d[0] }
        expect(destinations).to eq(expected_destinations)
      end
    end
  end

  describe '#current_destination' do
    let(:expected_current_destination) { '68fbb180-9a2a-48f6-9da6-545e28b8d35a' } # Do you like star wars?

    context 'when getting the list of destinations' do
      it 'returns the current destination for the page' do
        expect(destination.current_destination).to eq(expected_current_destination)
      end
    end
  end

  context 'when there are different branches point to the same page' do
    let(:page_flow) do
      service.flow_object(service.find_page_by_url('name').uuid)
    end
    let(:flow_objects) { [page_flow, page_flow] }
    let(:expected_destination_list) do
      [['Full name', '9e1ba77f-f1e5-42f4-b090-437aa9af7f73']]
    end

    before do
      allow_any_instance_of(Destination).to receive(:service).and_return(service)
    end

    it 'does not allow duplicate list items' do
      expect(
        destination.destinations_list(flow_objects: flow_objects)
      ).to eq(expected_destination_list)
    end
  end

  context 'when pages have the same titles' do
    let(:wrong_answers_page) do
      service.flow_object('6324cca4-7770-4765-89b9-1cdc41f49c8b')
    end
    let(:incomplete_answers_page) do
      service.flow_object('941137d7-a1da-43fd-994a-98a4f9ea6d46')
    end
    let(:flow_objects) { [wrong_answers_page, incomplete_answers_page] }
    let(:expected_destination_list) do
      [
        ['You are wrong', '6324cca4-7770-4765-89b9-1cdc41f49c8b'],
        ['You are wrong', '941137d7-a1da-43fd-994a-98a4f9ea6d46']
      ]
    end

    it 'will list both pages' do
      expect(
        destination.destinations_list(flow_objects: flow_objects)
      ).to eq(expected_destination_list)
    end
  end
end
