RSpec.describe 'Destinations spec', type: :request do
  describe 'GET /api/services/:service_id/flow/:flow_uuid/destinations/new' do
    let(:request) do
      get "/api/services/#{service.service_id}/flow/#{flow_uuid}/destinations/new"
    end
    let(:flow_uuid) { '9e1ba77f-f1e5-42f4-b090-437aa9af7f73' }

    context 'when changing the destination of a page' do
      let(:invalid_destinations) do
        [
          'Service name goes here',
          'Full name',
          'Confirmation'
        ]
      end
      let(:expected_destinations) do
        [
          'Email address',
          'Parent name',
          'Your age',
          'Family Hobbies',
          'Do you like Star Wars?',
          'What is the day that you like to take holidays?',
          'What would you like on your burger?',
          'How well do you know Star Wars?',
          'Tell me how many lights you see',
          'Upload your best dog photo',
          'Check your answers'
        ]
      end

      before do
        allow_any_instance_of(
          Api::DestinationsController
        ).to receive(:require_user!).and_return(true)

        allow_any_instance_of(
          Api::DestinationsController
        ).to receive(:service).and_return(service)

        request
      end

      it 'returns the list of possible destinations' do
        expected_destinations.each do |title|
          expect(response.body).to include(title)
        end
      end

      it 'does not include the start page, confirmation page or the page being changed' do
        invalid_destinations.each do |title|
          expect(response.body).not_to include(title)
        end
      end
    end
  end
end
