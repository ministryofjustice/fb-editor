RSpec.describe ReferenceNumberUpdater do
  subject(:reference_number_updater) do
    described_class.new(
      reference_number_settings: reference_number_settings,
      service_id: service.service_id
    )
  end
  let(:reference_number_settings) do
    ReferenceNumberSettings.new(
      params.merge(
        service_id: service.service_id
      )
    )
  end
  let(:params) { {} }
  let(:deployment_environment) { 'dev' }

  describe '#create_or_update' do
    context 'reference number' do
      context 'when reference_number exists in the db' do
        let!(:service_configuration) do
          create(
            :service_configuration,
            :dev,
            :reference_number,
            service_id: service.service_id
          )
        end

        let(:params) { { reference_number: '0' } }

        before do
          service_configuration
          allow(reference_number_updater).to receive(:remove_the_service_configuration)
        end

        context 'when a user unticked the box' do
          it 'updates the submission settings' do
            reference_number_updater.create_or_update!

            expect(reference_number_updater).to have_received(:remove_the_service_configuration).twice
          end
        end
      end

      context 'when reference_number doesn\'t exist in the db' do
        before do
          allow(reference_number_updater).to receive(:create_or_update_the_service_configuration)
        end

        context 'when a user ticks the box' do
          let(:params) { { reference_number: '1' } }

          it 'creates the submission settings' do
            reference_number_updater.create_or_update!

            expect(reference_number_updater).to have_received(:create_or_update_the_service_configuration).twice
          end
        end

        context 'when a user does not tick the box' do
          let(:params) { { reference_number: '0' } }

          it 'creates the submission settings' do
            reference_number_updater.create_or_update!

            expect(reference_number_updater).to_not have_received(:create_or_update_the_service_configuration)
          end
        end
      end
    end
  end
end
