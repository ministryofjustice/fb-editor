RSpec.describe SaveAndReturnSettingsUpdater do
  subject(:save_and_return_settings_updater) do
    described_class.new(
      save_and_return_settings:,
      service_id: service.service_id,
      service_name: service.service_name
    )
  end
  let(:save_and_return_settings) do
    SaveAndReturnSettings.new(
      params.merge(
        service_id: service.service_id
      )
    )
  end
  let(:params) { {} }

  describe '#create_or_update' do
    context 'when save_and_return exists in the db' do
      let(:params) { { save_and_return: '0' } }

      before do
        create(
          :service_configuration,
          :save_and_return,
          service_id: service.service_id,
          deployment_environment: 'dev'
        )
        create(
          :service_configuration,
          :save_and_return,
          service_id: service.service_id,
          deployment_environment: 'production'
        )

        save_and_return_settings_updater.create_or_update!
      end

      context 'when a user unticked the box' do
        it 'removes the configs from the database' do
          expect(
            ServiceConfiguration.where(
              service_id: service.service_id,
              name: 'SAVE_AND_RETURN'
            )
          ).to be_empty

          expect(
            ServiceConfiguration.where(
              service_id: service.service_id,
              name: 'SAVE_AND_RETURN_EMAIL'
            )
          ).to be_empty
        end
      end
    end

    context 'when save_and_return doesn\'t exist in the db' do
      context 'when a user ticks the box' do
        let(:params) { { save_and_return: '1' } }

        it 'creates the save and return settings' do
          save_and_return_settings_updater.create_or_update!

          expect(
            ServiceConfiguration.find_by(
              service_id: service.service_id,
              name: 'SAVE_AND_RETURN',
              deployment_environment: 'dev'
            )
          ).to be_present

          expect(
            ServiceConfiguration.find_by(
              service_id: service.service_id,
              name: 'SAVE_AND_RETURN_EMAIL',
              deployment_environment: 'dev'
            )
          ).to be_present

          expect(
            ServiceConfiguration.find_by(
              service_id: service.service_id,
              name: 'SAVE_AND_RETURN',
              deployment_environment: 'production'
            )
          ).to be_present

          expect(
            ServiceConfiguration.find_by(
              service_id: service.service_id,
              name: 'SAVE_AND_RETURN_EMAIL',
              deployment_environment: 'production'
            )
          ).to be_present
        end
      end

      context 'when a user does not tick the box' do
        let(:params) { { save_and_return: '0' } }

        it 'creates the submission settings' do
          save_and_return_settings_updater.create_or_update!

          expect(
            ServiceConfiguration.where(
              service_id: service.service_id,
              name: 'SAVE_AND_RETURN'
            )
          ).to be_empty

          expect(
            ServiceConfiguration.where(
              service_id: service.service_id,
              name: 'SAVE_AND_RETURN_EMAIL'
            )
          ).to be_empty
        end
      end
    end
  end
end
