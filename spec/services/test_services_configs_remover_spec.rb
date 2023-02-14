RSpec.describe TestServicesConfigsRemover do
  subject(:test_services_configs_remover) { described_class.new }

  context 'removing test services configurations' do
    let(:team_services) do
      {
        SecureRandom.uuid => [double(id: SecureRandom.uuid), double(id: SecureRandom.uuid)],
        SecureRandom.uuid => [double(id: SecureRandom.uuid), double(id: SecureRandom.uuid)]
      }
    end
    let(:non_team_services) do
      {
        SecureRandom.uuid => [double(id: SecureRandom.uuid), double(id: SecureRandom.uuid)],
        SecureRandom.uuid => [double(id: SecureRandom.uuid), double(id: SecureRandom.uuid)]
      }
    end
    let(:team_user_ids) { team_services.keys }
    let(:non_team_user_ids) { non_team_services.keys }
    let(:team_user_services) { team_services.values.flatten }
    let(:non_team_user_services) { non_team_services.values.flatten }

    before do
      allow(test_services_configs_remover).to receive(:user_ids).and_return(team_user_ids)
      team_services.merge(non_team_services).each do |user_id, _services|
        allow(MetadataApiClient::Service).to receive(:all)
          .with(user_id:)
          .and_return(team_user_services)
      end
      (team_user_services + non_team_user_services).each do |service|
        create(
          :service_configuration,
          :service_email_output,
          service_id: service.id,
          deployment_environment: 'dev'
        )
        create(
          :publish_service,
          service_id: service.id,
          deployment_environment: 'dev',
          status: 'completed'
        )
        create(:submission_setting, service_id: service.id, deployment_environment: 'dev')
        create(:from_address, service_id: service.id)
      end

      test_services_configs_remover.call
    end

    it 'should remove the non team services configurations' do
      non_team_user_services.each do |service|
        expect(ServiceConfiguration.where(service_id: service.id)).to be_empty
        expect(SubmissionSetting.where(service_id: service.id)).to be_empty
        expect(PublishService.where(service_id: service.id)).to be_empty
        expect(FromAddress.where(service_id: service.id)).to be_empty
      end
    end

    it 'should not remove the team service configurations' do
      team_user_services.each do |service|
        expect(ServiceConfiguration.where(service_id: service.id)).to_not be_empty
        expect(SubmissionSetting.where(service_id: service.id)).to_not be_empty
        expect(PublishService.where(service_id: service.id)).to_not be_empty
        expect(FromAddress.where(service_id: service.id)).to_not be_empty
      end
    end
  end
end
