RSpec.describe 'Authorisation spec', type: :request do
  let(:service) { MetadataPresenter::Service.new(metadata_fixture(:branching)) }
  let(:current_user) { double(id: SecureRandom.uuid, email: 'steven.grant@khonshu.eg') }
  let(:expected_unauthorised_path) { unauthorised_path }

  before do
    allow_any_instance_of(ApplicationController).to receive(:require_user!).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)
    allow_any_instance_of(ApplicationController).to receive(:service).and_return(service)
    allow(MetadataApiClient::Items).to receive(:all).and_return({})
  end

  context 'all services page' do
    let(:request) { get '/services' }

    before do
      allow_any_instance_of(ServicesController).to receive(:services).and_return([])
      request
    end

    it 'does not call authorised_access' do
      expect_any_instance_of(ServicesController).not_to receive(:authorised_access)
    end

    it 'responds successfully' do
      expect(response.status).to be(200)
    end
  end

  shared_examples 'an authorisation action' do
    context 'when admin user' do
      before do
        allow_any_instance_of(PermissionsController).to receive(:moj_forms_admin?).and_return(true)
      end

      it 'allows access' do
        request
        expect(response.status).to eq(200)
      end
    end

    context 'when service creator' do
      before do
        allow(service).to receive(:created_by).and_return(current_user.id)
      end

      it 'allows access' do
        request
        expect(response.status).to eq(200)
      end
    end

    context 'when not the service creator or admin user' do
      it 'does not allow access' do
        expect(request).to redirect_to(expected_unauthorised_path)
      end
    end
  end

  context 'editing a service' do
    it_behaves_like 'an authorisation action' do
      let(:request) { get "/services/#{service.service_id}/edit" }
    end
  end

  context 'editing a page' do
    it_behaves_like 'an authorisation action' do
      let(:request) do
        get "/services/#{service.service_id}/pages/#{service.start_page.uuid}/edit"
      end
    end
  end

  context 'editing a branch' do
    it_behaves_like 'an authorisation action' do
      let(:branch) { service.branches.first }
      let(:request) do
        get "/services/#{service.service_id}/branches/#{branch.uuid}/edit"
      end
    end
  end

  context 'visiting the publishing page' do
    it_behaves_like 'an authorisation action' do
      let(:request) { get "/services/#{service.service_id}/publish" }
    end
  end

  context 'visiting the settings page' do
    it_behaves_like 'an authorisation action' do
      let(:request) { get "/services/#{service.service_id}/settings" }
    end
  end

  context 'previewing a form' do
    it_behaves_like 'an authorisation action' do
      let(:request) { get "/services/#{service.service_id}/preview" }
      let(:expected_unauthorised_path) { 'http://www.example.com/unauthorised' }
    end
  end
end
