RSpec.describe FormUrlUpdater do
  subject(:form_name_updater) do
    described_class.new(
      service_id: service.service_id,
      service_slug: params
    )
  end
  let(:current_user) { double(id: '1') }
  let(:service_configuration) do
    ServiceConfiguration.find_by(
      service_id: service.service_id,
      name: 'SERVICE_SLUG'
    )
  end
  let(:previous_slug_service_config) do
    ServiceConfiguration.find_by(
      service_id: service.service_id,
      name: 'PREVIOUS_SERVICE_SLUG'
    )
  end

  describe '#create_or_update' do
    context 'on form update' do
      before do
        create(
          :service_configuration,
          :service_slug,
          service_id: service.service_id,
          deployment_environment: 'dev'
        )
        create(
          :service_configuration,
          :service_slug,
          service_id: service.service_id,
          deployment_environment: 'production'
        )
      end

      context 'when service has been published' do
        let(:params) { 'i-am-a-unique-service' }
        let(:expected_service_slug) { 'i-am-a-unique-service' }
        let(:previous_service_slug) { 'eat-slugs-malfoy' }

        before do
          allow_any_instance_of(FormUrlUpdater).to receive(:currently_published?).and_return(true)
        end

        context 'when previous service slug config does not exist' do
          it 'creates a previous service slug config and updates service slug config' do
            form_name_updater.create_or_update!
            service_configuration.reload
            expect(
              previous_slug_service_config.decrypt_value
            ).to eq(previous_service_slug)
            expect(
              service_configuration.decrypt_value
            ).to eq(expected_service_slug)
          end
        end

        context 'when previous service slug exists' do
          let(:previous_service_slug) { 'slug-life' }

          before do
            create(
              :service_configuration,
              :previous_service_slug,
              service_id: service.service_id,
              deployment_environment: 'dev'
            )
            create(
              :service_configuration,
              :previous_service_slug,
              service_id: service.service_id,
              deployment_environment: 'production'
            )
          end

          it 'updates service slug config only' do
            form_name_updater.create_or_update!
            service_configuration.reload
            expect(
              previous_slug_service_config.decrypt_value
            ).to eq(previous_service_slug)
            expect(
              service_configuration.decrypt_value
            ).to eq(expected_service_slug)
          end
        end
      end

      context 'when service is not currently published' do
        context 'and previous service slug does not exist' do
          let(:params) { 'i-am-a-unique-service' }
          let(:expected_service_slug) { 'i-am-a-unique-service' }

          it 'updates the existing service slug config' do
            form_name_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq(expected_service_slug)
          end

          it 'does not create a previous service slug config' do
            form_name_updater.create_or_update!
            service_configuration.reload
            expect(
              previous_slug_service_config.present?
            ).to be_falsey
          end
        end

        context 'and previous service slug exists' do
          let(:params) { 'i-am-a-unique-service' }
          let(:expected_service_slug) { 'i-am-a-unique-service' }

          before do
            create(
              :service_configuration,
              :previous_service_slug,
              service_id: service.service_id,
              deployment_environment: 'dev'
            )
            create(
              :service_configuration,
              :previous_service_slug,
              service_id: service.service_id,
              deployment_environment: 'production'
            )
          end

          it 'updates the existing service slug config' do
            form_name_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq(expected_service_slug)
          end

          it 'removes the previous service slug config' do
            form_name_updater.create_or_update!
            service_configuration.reload
            expect(
              previous_slug_service_config.present?
            ).to be_falsey
          end
        end
      end
    end

    context 'when SERVICE_CONFIG does not exist' do
      let(:params) { 'i-am-a-unique-service' }
      let(:expected_service_slug) { 'i-am-a-unique-service' }

      it 'creates a SERVICE_CONFIG' do
        form_name_updater.create_or_update!
        service_configuration.reload
        expect(
          service_configuration.decrypt_value
        ).to eq(expected_service_slug)
      end
    end
  end
end
