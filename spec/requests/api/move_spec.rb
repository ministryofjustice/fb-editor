RSpec.describe 'Move GET routes', type: :routing do
  context 'when previous_flow_uuid is present' do
    let(:request) do
      get '/api/services/some-service-id/flow/some-flow-uuid/move/some-previous-flow-uuid'
    end
    let(:expected_route) do
      {
        controller: 'api/move',
        action: 'targets',
        service_id: 'some-service-id',
        flow_uuid: 'some-flow-uuid',
        previous_flow_uuid: 'some-previous-flow-uuid'
      }
    end

    it 'correctly routes the request' do
      expect(request).to route_to(expected_route)
    end
  end

  context 'when previous_flow_uuid is not present' do
    let(:request) do
      get '/api/services/some-service-id/flow/some-flow-uuid/move'
    end
    let(:expected_route) do
      {
        controller: 'api/move',
        action: 'targets',
        service_id: 'some-service-id',
        flow_uuid: 'some-flow-uuid'
      }
    end

    it 'correctly routes the request' do
      expect(request).to route_to(expected_route)
    end
  end
end

RSpec.describe 'Move spec', type: :request do
  describe 'GET /api/services/:service_id/flow/:flow_uuid/move/(:previous_flow_uuid)' do
    let(:request) do
      get "/api/services/#{service.service_id}/flow/#{flow_uuid}/move/#{previous_flow_uuid}"
    end
    let(:service) { MetadataPresenter::Service.new(metadata) }
    let(:metadata) { metadata_fixture(:branching_11) }
    let(:flow_uuid) { '2ffc17b7-b14a-417f-baff-07adebd4f259' } # Page B
    let(:previous_flow_uuid) { '1d60bef0-100a-4f3b-9e6f-1711e8adda7e' } # Page A

    context 'when moving a page' do
      let(:invalid_targets) do
        [
          'Check your answers',
          'Confirmation'
        ]
      end
      let(:unconnected_targets) do
        [
          'Page Q',
          'Page R',
          'Page S'
        ]
      end
      let(:expected_targets) do
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
      let(:expected_branch_and_conditionals) do
        [
          'data-conditional-uuid="9149bc4c-9773-454f-b9b6-5524b91102ca"',
          'data-conditional-uuid="6c4dd853-671d-4f62-845e-6471bd102e36"',
          'data-conditional-uuid=""',
          'data-conditional-uuid="db2676e0-3cef-4943-af00-3ddbece930d2"',
          'data-conditional-uuid="0b99ff9b-e9db-47ff-acf9-c15b00113a13"',
          'data-conditional-uuid="e3f94a86-a371-47fb-b866-1909b055316d"',
          'data-conditional-uuid="7c013bb4-abc7-4270-a0c2-fd70715839b6"',
          'data-conditional-uuid=""',
          'data-conditional-uuid="0bdc8fde-be62-4945-8496-854e867a665d"',
          'data-conditional-uuid="4ad9f7e9-5444-41d8-b7f8-17d2108ed27a"',
          'data-conditional-uuid=""',
          'data-conditional-uuid="7b69e2fb-a18b-405e-b47e-75970e6f5e4b"',
          'data-conditional-uuid=""'
        ]
      end
      let(:selected_target) do
        '<option value="1d60bef0-100a-4f3b-9e6f-1711e8adda7e" data-conditional-uuid="" selected="selected">'
      end

      before do
        allow_any_instance_of(
          Api::MoveController
        ).to receive(:require_user!).and_return(true)

        allow_any_instance_of(
          Api::MoveController
        ).to receive(:service).and_return(service)

        request
      end

      it 'returns the list of possible targets' do
        expected_targets.each do |title|
          expect(response.body).to include(title)
        end
      end

      it 'returns the correct branch and conditional uuids for branch targets' do
        expected_branch_and_conditionals.each do |branch_and_conditional|
          expect(response.body).to include(branch_and_conditional)
        end
      end

      it 'does not include any unconnected targets' do
        unconnected_targets.each do |title|
          expect(response.body).not_to include(title)
        end
      end

      it 'does not include the checkanswers, confirmation page or the page being moved' do
        invalid_targets.each do |title|
          expect(response.body).not_to include(title)
        end
      end

      it 'sets the selected attribute for the previous target' do
        expect(response.body).to include(selected_target)
      end
    end
  end

  describe 'POST /api/services/:service_id/flow/:flow_uuid/move' do
    let(:request) do
      post "/api/services/#{service.service_id}/flow/#{flow_uuid}/move", params: params
    end
    let(:service) { MetadataPresenter::Service.new(metadata) }
    let(:metadata) { metadata_fixture(:branching_11) }
    let(:version) { double(errors?: false, metadata: metadata) }
    let(:flow_uuid) { '2ffc17b7-b14a-417f-baff-07adebd4f259' } # Page B
    let(:params) do
      {
        move: {
          previous_flow_uuid: '1d60bef0-100a-4f3b-9e6f-1711e8adda7e', # Page A
          target_uuid: '007f4f35-8236-40cc-866c-cc2c27c33949', # Page E
          conditional_uuid: ''
        }
      }
    end

    before do
      allow_any_instance_of(
        Api::MoveController
      ).to receive(:require_user!).and_return(true)

      allow_any_instance_of(
        Api::MoveController
      ).to receive(:service).and_return(service)

      allow(MetadataApiClient::Version).to receive(:create).and_return(version)
    end

    it 'redirects to the service edit page' do
      request
      expect(response).to redirect_to(edit_service_path(service.service_id))
    end

    it 'changes the metadata' do
      expect_any_instance_of(Move).to receive(:change)
      request
    end
  end
end
