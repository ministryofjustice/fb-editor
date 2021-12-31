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

  describe 'POST /api/services/:service_id/flow/:flow_uuid/destinations/create' do
    let(:service) { MetadataPresenter::Service.new(metadata) }
    let(:metadata) { metadata_fixture(:branching_2) }
    let(:request) do
      post "/api/services/#{service.service_id}/flow/#{flow_uuid}/destinations",
           params: { destination_uuid: destination_uuid }
    end
    let(:flow_uuid) { '393645a4-f037-4e75-8359-51f9b0e360fb' }
    let(:destination_uuid) { '68fbb180-9a2a-48f6-9da6-545e28b8d35a' }
    let(:version) do
      double(errors?: false, metadata: metadata)
    end

    before do
      allow_any_instance_of(
        Api::DestinationsController
      ).to receive(:require_user!).and_return(true)

      allow_any_instance_of(
        Api::DestinationsController
      ).to receive(:service).and_return(service)

      allow(MetadataApiClient::Version).to receive(:create).and_return(
        version
      )
    end

    context 'when the change does not disconnect the CYA or confirmation pages' do
      it 'changes the destination' do
        expect_any_instance_of(Destination).to receive(:change)
        request
      end
    end

    context 'disconnecting CYA and confirmation pages' do
      let(:metadata) { metadata_fixture(:version) }

      context 'without user confirmation' do
        shared_examples 'redirect with confirmation modal' do
          it 'does not change the destination' do
            expect_any_instance_of(Destination).not_to receive(:change)
            request
          end

          it 'redirects with the correct params' do
            request
            expect(response).to redirect_to(expected_redirect_url)
          end
        end
        let(:expected_redirect_url) { "/services/#{service.service_id}/edit?destination_uuid=#{destination_uuid}&flow_uuid=#{flow_uuid}" }

        context 'when the change disconnects CYA page' do
          it_behaves_like 'redirect with confirmation modal' do
            let(:flow_uuid) { '2ef7d11e-0307-49e9-9fe2-345dc528dd66' } # dog-picture
            let(:destination_uuid) { '778e364b-9a7f-4829-8eb2-510e08f156a3' } # confirmation page
          end
        end

        context 'when the change disconnects the confirmation page' do
          it_behaves_like 'redirect with confirmation modal' do
            let(:flow_uuid) { 'e337070b-f636-49a3-a65c-f506675265f0' } # checkanswers
            let(:destination_uuid) { 'cf6dc32f-502c-4215-8c27-1151a45735bb' } # start page
          end
        end

        context 'when the change disconnects both CYA and confirmation pages' do
          it_behaves_like 'redirect with confirmation modal' do
            let(:flow_uuid) { '2ef7d11e-0307-49e9-9fe2-345dc528dd66' } # dog-picture
          end
        end
      end

      context 'with user confirmation' do
        shared_examples 'change destination with user confirmation' do
          it 'does change the destination' do
            expect_any_instance_of(Destination).to receive(:change)
            request
          end

          it 'redirects with the correct params' do
            request
            expect(response).to redirect_to(expected_redirect_url)
          end
        end

        let(:request) do
          post "/api/services/#{service.service_id}/flow/#{flow_uuid}/destinations",
               params: {
                 destination_uuid: destination_uuid,
                 user_confirmation: 'true'
               }
        end
        let(:expected_redirect_url) { "/services/#{service.service_id}/edit" }

        context 'change disconnects CYA page' do
          it_behaves_like 'change destination with user confirmation' do
            let(:flow_uuid) { '2ef7d11e-0307-49e9-9fe2-345dc528dd66' } # dog-picture
            let(:destination_uuid) { '778e364b-9a7f-4829-8eb2-510e08f156a3' } # confirmation page
          end
        end

        context 'change disconnects confirmation page' do
          it_behaves_like 'change destination with user confirmation' do
            let(:flow_uuid) { 'e337070b-f636-49a3-a65c-f506675265f0' } # checkanswers
            let(:destination_uuid) { 'cf6dc32f-502c-4215-8c27-1151a45735bb' } # start page
          end
        end

        context 'change disconnects CYA and confirmation pages' do
          it_behaves_like 'change destination with user confirmation' do
            let(:flow_uuid) { '2ef7d11e-0307-49e9-9fe2-345dc528dd66' } # dog-picture
          end
        end
      end
    end
  end
end
