RSpec.describe Unpublisher::Adapters::CloudPlatform do
  subject(:cloud_platform) do
    described_class.new(attributes)
  end
  let(:attributes) do
    {
      publish_service:,
      platform_environment: 'dev',
      service_slug:
    }
  end
  let(:publish_service) do
    create(
      :publish_service,
      :dev,
      service_id: SecureRandom.uuid,
      status: 'queued'
    )
  end
  let(:service_slug) { 'sluggy-mcslugface' }

  describe '#unpublishing' do
    before do
      allow(cloud_platform).to receive(:config_present?).and_return(true)
      allow(cloud_platform).to receive(:removal_service).and_return(k8s_config_removal_service)
      cloud_platform.unpublishing
    end

    context 'when successfully unpublishing' do
      let(:k8s_config_removal_service) { double(delete: true) }

      it 'updates the status of the publish service to unpublishing' do
        expect(publish_service.reload.status).to eq('unpublishing')
      end
    end

    context 'when config does not exist' do
      let(:k8s_config_removal_service) { double(delete: false) }

      it 'does not attempt to delete the configuration' do
        expect(k8s_config_removal_service).not_to receive(:delete).with(
          config: 'configmap',
          name: "fb-#{service_slug}-config-map"
        )
      end
    end
  end

  describe '#unpublished' do
    before do
      allow(NotificationService).to receive(:notify)
    end

    it 'updates the status of the publish service to unpublished' do
      cloud_platform.unpublished
      expect(publish_service.reload.status).to eq('unpublished')
    end

    it 'sends a notification' do
      expect(NotificationService).to receive(:notify).with(
        'sluggy-mcslugface has been unpublished from formbuilder-services-dev-dev'
      ).and_return(true)
      cloud_platform.unpublished
    end
  end
end
