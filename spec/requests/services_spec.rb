RSpec.describe 'Services' do
  let(:current_user) do
    double(id: SecureRandom.uuid)
  end
  let(:service_updater) do
    double(create_flow: true, update: true)
  end

  describe 'GET /services/:id/edit' do
    before do
      expect_any_instance_of(ApplicationController).to receive(:service).at_least(:once).and_return(service)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)
      allow_any_instance_of(PermissionsController).to receive(:require_user!).and_return(true)
    end

    context 'when there is no flow object in the service metadata' do
      let(:service) do
        MetadataPresenter::Service.new(metadata_fixture('no_flow_service'))
      end

      it 'will call the service updater' do
        expect(ServiceUpdater).to receive(:new).with(
          service.metadata
        ).and_return(service_updater)
        expect(service_updater).to receive(:create_flow)

        get "/services/#{service.service_id}/edit"
      end
    end

    context 'when a flow object exists in the metadata' do
      let(:service) do
        MetadataPresenter::Service.new(metadata_fixture('branching'))
      end

      it 'does not call the service updater' do
        expect(ServiceUpdater).not_to receive(:new)
        get "/services/#{service.service_id}/edit"
      end
    end
  end
end
