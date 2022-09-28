RSpec.describe 'Move GET routes', type: :routing do
  context 'when previous_flow_uuid is present' do
    let(:service_id) { 'some-service-id' }
    let(:flow_uuid) { 'some-flow-uuid' }
    let(:previous_flow_uuid) { 'some-previous-flow-uuid' }
    let(:move_route) do
      {
        controller: 'api/move',
        action: 'targets',
        service_id: service_id,
        flow_uuid: flow_uuid,
        previous_flow_uuid: previous_flow_uuid
      }
    end

    context 'when previous conditional uuid is not present' do
      let(:request) do
        get "/api/services/#{service_id}/flow/#{flow_uuid}/move/#{previous_flow_uuid}"
      end
      let(:expected_route) { move_route }

      it 'correctly routes the request' do
        expect(request).to route_to(expected_route)
      end
    end

    context 'when previous conditional uuid is present' do
      let(:request) do
        get "/api/services/#{service_id}/flow/#{flow_uuid}/move/#{previous_flow_uuid}/#{previous_conditional_uuid}"
      end
      let(:previous_conditional_uuid) { 'some-previous-conditional-uuid' }
      let(:expected_route) do
        move_route.merge(previous_conditional_uuid: previous_conditional_uuid)
      end

      it 'correctly routes the request' do
        expect(request).to route_to(expected_route)
      end
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
  describe 'GET /api/services/:service_id/flow/:flow_uuid/move/(:previous_flow_uuid)/(:previous_conditional_uuid' do
    let(:service) { MetadataPresenter::Service.new(metadata) }
    let(:metadata) { metadata_fixture(:branching_11) }
    let(:flow_uuid) { '2ffc17b7-b14a-417f-baff-07adebd4f259' } # Page B
    let(:previous_flow_uuid) { '1d60bef0-100a-4f3b-9e6f-1711e8adda7e' } # Page A

    before do
      allow_any_instance_of(
        Api::MoveController
      ).to receive(:require_user!).and_return(true)

      allow_any_instance_of(
        Api::MoveController
      ).to receive(:service).and_return(service)

      request
    end

    context 'when previous conditional uuid is not present' do
      let(:request) do
        get "/api/services/#{service.service_id}/flow/#{flow_uuid}/move/#{previous_flow_uuid}"
      end
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
      let(:previous_uuid_field) do
        '<input value="1d60bef0-100a-4f3b-9e6f-1711e8adda7e" autocomplete="off" type="hidden" name="move[previous_flow_uuid]" id="move_previous_flow_uuid" />'
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

      it 'sets the hidden field for the previous uuid' do
        expect(response.body).to include(previous_uuid_field)
      end
    end

    context 'when previous conditional uuid is present' do
      let(:request) do
        get "/api/services/#{service.service_id}/flow/#{flow_uuid}/move/#{previous_flow_uuid}/#{previous_conditional_uuid}"
      end
      let(:flow_uuid) { '1314e473-9096-4434-8526-03a7b4b7b132' } # Page K
      let(:previous_flow_uuid) { 'a02f7073-ba5a-459d-b6b9-abe548c933a6' } # Branching Point 2
      let(:previous_conditional_uuid) { '0bdc8fde-be62-4945-8496-854e867a665d' }
      let(:selected_target) do
        '<option value="a02f7073-ba5a-459d-b6b9-abe548c933a6" data-conditional-uuid="0bdc8fde-be62-4945-8496-854e867a665d" selected="selected">'
      end
      let(:previous_conditional_uuid_field) do
        '<input value="0bdc8fde-be62-4945-8496-854e867a665d" autocomplete="off" type="hidden" name="move[previous_conditional_uuid]" id="move_previous_conditional_uuid" />'
      end

      it 'sets the selected attribute for the previous target' do
        expect(response.body).to include(selected_target)
      end

      it 'sets the previous conditional uuid hidden field' do
        expect(response.body).to include(previous_conditional_uuid_field)
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
          target_conditional_uuid: ''
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

    context 'undo' do
      it 'set the session key \'undo\' to \'undo move\'' do
        request
        expect(session[:undo]).to  eq(I18n.t('actions.undo_redo.undo_move'))
      end
    end

    context 'undo when move is invalid' do
      before do
        allow_any_instance_of(Move).to receive(:valid?).and_return(false)
      end

      it 'doesn\'t set to \'move\' if move is invalid' do
        request
        expect(session[:undo]).to be_falsey
      end
    end
  end
end
