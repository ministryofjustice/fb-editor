RSpec.describe 'GET /services/:service_id/preview' do
  let(:request) { get "/services/#{service.service_id}/preview" }
  let(:current_user) { double(id: service.created_by, email: 'peter.quill@milano.com') }

  context 'when user is not signed in' do
    before { request }

    it 'redirects to root path' do
      expect(response).to redirect_to('/')
    end
  end

  context 'when user is signed in' do
    before do
      allow_any_instance_of(
        PermissionsController
      ).to receive(:require_user!).and_return(true)
      expect_any_instance_of(
        ApplicationController
      ).to receive(:service).at_least(:once).and_return(service)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)
      request
    end

    it 'responds successfully' do
      expect(response.status).to be(200)
    end
  end
end
