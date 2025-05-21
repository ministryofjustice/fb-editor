RSpec.describe 'MS List Settings' do
  let(:current_user) { double(id: service.created_by, email: 'bishop@sulaco.com') }
  let(:settings) { MsListSetting.new(params.merge(service:)) }
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
      # the localisation contains quotes so is encoded in the body response
      expect(response.body).to include('The Teams site must be in the main &quot;Ministry of Justice&quot; Microsoft tenant. The tenant is shown on your profile whenever you are signed into MS 365')
      expect(response.status).to be(422)
    end
  end

  describe 'graph api returns server error' do
    let(:error_message) { 'Internal server error' }
    before do
      post "/services/#{service.service_id}/settings/ms_list", params: { ms_list_setting: params }
    end

    it 'will render index with unprocessable entity' do
      expect(response.body).to include(I18n.t('settings.ms_list.errors.server_error'))
      expect(response.status).to be(422)
    end
  end
end
