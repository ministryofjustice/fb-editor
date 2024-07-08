RSpec.describe 'MS List Settings' do
  let(:current_user) { double(id: service.created_by, email: 'bishop@sulaco.com') }
  let(:settings) { MsListSetting.new(params.merge(service:))}
  let(:params) do 
    { ms_site_id: SecureRandom.uuid, deployment_environment: 'dev', send_to_ms_list: '1' }
  end

  before do
    allow_any_instance_of(
      PermissionsController
    ).to receive(:require_user!).and_return(true)

    expect_any_instance_of(
      ApplicationController
    ).to receive(:service).at_least(:once).and_return(service)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)
    allow_any_instance_of(MsListSettingsUpdater).to receive(:create_or_update!).and_raise(StandardError.new(error_message))
  end

  describe 'graph api returns forbidden' do
    let(:error_message) { 'Forbidden' }
    before do
      post "/services/#{service.service_id}/settings/ms_list", params: { ms_list_setting: params }
    end

    it 'will render index with unprocessable entity' do
      expect(response.body).to include('The SharePoint site must be in MoJ’s main Microsoft 365 tenancy which requires an @justice email address to access it.')
      expect(response.status).to be(422)
    end
  end

  describe 'graph api returns server error' do
    let(:error_message) { 'Internal server error' }
    before do
      post "/services/#{service.service_id}/settings/ms_list", params: { ms_list_setting: params }
    end

    it 'will render index with unprocessable entity' do
      expect(response.body).to include('There was a problem and we were unable to set up your Microsoft List. Try again or contact us if the problem persists.')
      expect(response.status).to be(422)
    end
  end

end
