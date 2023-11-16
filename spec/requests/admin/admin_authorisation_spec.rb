RSpec.describe 'Admin authorisation spec', type: :request do
  let(:service) { MetadataPresenter::Service.new(metadata_fixture(:branching)) }
  let(:current_user) { double(id: SecureRandom.uuid, email: 'ellen.ripley@nostromo.eg') }

  before do
    allow_any_instance_of(Admin::ApplicationController).to receive(:require_user!).and_return(true)
    allow_any_instance_of(
      Admin::ApplicationController
    ).to receive(:current_user).and_return(current_user)
  end

  it_behaves_like 'a controller that stores the current request details' do
    let(:path) { admin_root_path }
  end

  shared_examples 'an authorisation action' do
    context 'when admin user' do
      before do
        allow_any_instance_of(
          Admin::ApplicationController
        ).to receive(:moj_forms_dev?).and_return(true)
      end

      it 'allows access' do
        request
        expect(response.status).to eq(200)
      end
    end

    context 'when not admin user' do
      it 'does not allow access' do
        expect(request).to redirect_to(unauthorised_path)
      end
    end
  end

  context 'when admin dashboard root' do
    it_behaves_like 'an authorisation action' do
      let(:request) { get admin_root_path }
    end
  end

  context 'when overviews page' do
    it_behaves_like 'an authorisation action' do
      let(:request) { get '/admin/overviews' }
    end
  end

  context 'when legacy service name page' do
    it_behaves_like 'an authorisation action' do
      let(:request) { get '/admin/legacy_service_names' }
    end
  end

  context 'when uptime checks page' do
    it_behaves_like 'an authorisation action' do
      let(:request) { get '/admin/uptime_checks' }

      before do
        allow_any_instance_of(
          Admin::UptimeChecksController
        ).to receive(:services_without_uptime_checks).and_return([])
        allow_any_instance_of(
          Admin::UptimeChecksController
        ).to receive(:with_uptime_checks).and_return([])
        allow_any_instance_of(
          Admin::UptimeChecksController
        ).to receive(:non_editor_service_checks).and_return([])
      end
    end
  end

  context 'when services page' do
    it_behaves_like 'an authorisation action' do
      let(:request) { get '/admin/services' }
      let(:all_services) do
        {
          services: [],
          total_count: 0,
          page: 1,
          per_page: 10
        }
      end

      before do
        allow(MetadataApiClient::Service).to receive(:all_services).and_return(all_services)
      end
    end
  end

  context 'when users page' do
    it_behaves_like 'an authorisation action' do
      let(:request) { get '/admin/users' }
    end
  end

  context 'when publish services page' do
    it_behaves_like 'an authorisation action' do
      let(:request) { get '/admin/publish_services' }
    end
  end
end
