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
    context 'on form creation' do
      let(:params) { ServiceCreation.new(attributes).service_name }

      context 'when service slug is unique' do
        let(:attributes) { { service_name: 'I am a unique service' } }
        let(:expected_service_slug) { 'i-am-a-unique-service' }

        it 'updates the service configuration subject' do
          form_name_updater.create_or_update!
          service_configuration.reload
          expect(
            service_configuration.decrypt_value
          ).to eq(expected_service_slug)
        end
      end

      context 'when there is a duplicate service slug' do
        let!(:existing_service_configuration) do
          create(
            :service_configuration,
            :dev,
            :service_slug,
            service_id: SecureRandom.uuid
          )
        end
        let(:attributes) { { service_name: 'Eat slugs malfoy' } }
        let(:expected_service_slug) { 'eat-slugs-malfoy' }

        it 'changes the last three characters for uniqueness' do
          form_name_updater.create_or_update!
          service_configuration.reload
          expect(
            service_configuration.decrypt_value.last(3)
          ).to_not eq(expected_service_slug.last(3))
          expect(
            service_configuration.decrypt_value.first(12)
          ).to eq(expected_service_slug.first(12))
        end

        context 'when there is a duplicate previous service slug config' do
          let!(:existing_service_configuration) do
            create(
              :service_configuration,
              :dev,
              :previous_service_slug,
              service_id: SecureRandom.uuid
            )
          end
          let(:attributes) { { service_name: 'Slug Life' } }
          let(:expected_service_slug) { 'slug-life' }

          it 'changes the last three characters for uniqueness' do
            form_name_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value.last(3)
            ).to_not eq(expected_service_slug.last(3))
            expect(
              service_configuration.decrypt_value.first(6)
            ).to eq(expected_service_slug.first(6))
          end
        end
      end

      context 'when service name is longer than 57 chars' do
        let(:attributes) do
          {
            service_name: 'This is a very very very very long service name cut me off now'
          }
        end
        let(:expected_service_slug) { 'this-is-a-very-very-very-very-long-service-name-cut-me-of' }

        it 'creates a service configuration object with 57 characters' do
          form_name_updater.create_or_update!
          service_configuration.reload
          expect(
            service_configuration.decrypt_value.length
          ).to eq(57)
          expect(
            service_configuration.decrypt_value
          ).to eq(expected_service_slug)
        end
      end

      context 'when service name contains special characters' do
        let(:attributes) do
          {
            service_name: 'All 0f the ("special") characters?!'
          }
        end
        let(:expected_service_slug) { 'all-0f-the-special-characters' }

        it 'creates a unique service configuration object removing non-alphanumeric characters' do
          form_name_updater.create_or_update!
          service_configuration.reload
          expect(
            service_configuration.decrypt_value
          ).to eq(expected_service_slug)
        end
      end

      context 'when the form name begins with a number' do
        let(:attributes) do
          {
            service_name: '123remove the prefix 123'
          }
        end
        let(:expected_service_slug) { 'remove-the-prefix-123' }

        it 'removes the leading numbers' do
          form_name_updater.create_or_update!
          service_configuration.reload
          expect(
            service_configuration.decrypt_value
          ).to eq(expected_service_slug)
        end
      end
    end

    context 'on form update' do
      context 'when service has been published' do
        let(:params) { 'I am a unique service' }
        let(:expected_service_slug) { 'i-am-a-unique-service' }
        let(:previous_service_slug) { 'eat-slugs-malfoy' }

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
    end
  end
end
