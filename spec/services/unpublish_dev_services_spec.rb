require 'rails_helper'

RSpec.describe UnpublishDevServices do
  subject(:unpublish_dev_services) { described_class.new }

  describe '#call' do
    RSpec.shared_examples 'call' do
      let(:version_metadata) { metadata_fixture(:version) }
      let(:params) do
        {
          publish_service_id: published_services.id,
          service_slug: service_slug_config
        }
      end

      before do
        allow(unpublish_dev_services).to receive(:get_version_metadata).and_return(version_metadata)
        allow(UnpublishServiceJob).to receive(:perform_later).and_call_original
        allow(UnpublishServiceJob).to receive(:perform_later).with(params)

        unpublish_dev_services.call
      end

      context 'when service is in dev' do
        let(:published_services) do
          create(
            :publish_service,
            :dev,
            service_id: SecureRandom.uuid,
            status: 'completed'
          )
        end

        it 'should unpublish the service' do
          expect(UnpublishServiceJob).to have_received(:perform_later).with(params)
        end
      end

      context 'when service is in production' do
        let(:published_services) do
          create(
            :publish_service,
            :production,
            service_id: SecureRandom.uuid,
            status: 'completed'
          )
        end

        it 'should not unpublish the service' do
          expect(UnpublishServiceJob).to_not have_received(:perform_later).with(params)
        end
      end

      context 'when service is in an automated test service' do
        UnpublishDevServices::AUTOMATED_TEST_SERVICES.each do |service_id|
          let(:published_services) do
            create(
              :publish_service,
              :dev,
              service_id:,
              status: 'completed'
            )
          end

          it 'should not unpublish the automated test service' do
            expect(UnpublishServiceJob).to_not have_received(:perform_later).with(params)
          end
        end
      end
    end

    context 'when service slug is from service config' do
      let(:service_slug_config) do
        ServiceConfiguration.find_by(
          service_id: service.service_id,
          name: 'SERVICE_SLUG'
        )
      end
      before do
        allow(subject).to receive(:service_slug).and_return(service_slug_config)
      end
      it_behaves_like 'call'
    end

    context 'when service slug is from service name' do
      let(:service_slug_config) { 'version-fixture' }
      before do
        allow(subject).to receive(:service_slug).and_return(service_slug_config)
      end
      it_behaves_like 'call'
    end
  end
end
