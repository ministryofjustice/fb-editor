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
          'How well do you know Star Wars?',
          'What is your favourite fruit?',
          'Do you like apple juice?',
          'Do you like orange juice?',
          'What is your favourite band?',
          'Which app do you use to listen music?',
          'What is the best form builder?',
          'Which Formbuilder is the best?',
          'What would you like on your burger?',
          'Global warming',
          'We love chickens',
          'What is the best marvel series?',
          'Loki',
          'Other quotes',
          'Select all Arnold Schwarzenegger quotes',
          'You are right',
          'You are wrong',
          'You are wrong',
          'Check your answers',
          'Branching point 1',
          'Branching point 2',
          'Branching point 3',
          'Branching point 4',
          'Branching point 5',
          'Branching point 6',
          'Branching point 7'
        ]
      end

      it 'returns branches and pages without start, confirmation and the page that is being changed' do
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
end
