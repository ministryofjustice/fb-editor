RSpec.describe ReferenceNumberUpdater do
  subject(:reference_number_updater) do
    described_class.new(
      reference_number_settings: reference_number_settings,
      service_id: service.service_id,
      service_name: service.service_name
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

  describe '#create_or_update' do
    RSpec.shared_examples 'reference number service configuration' do
      context 'reference number' do
        context 'when reference_number exists in the db' do
          let!(:service_configuration) do
            create(
              :service_configuration,
              :reference_number,
              service_id: service.service_id,
              deployment_environment: deployment_environment
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

      context 'confirmation email subject' do
        let!(:service_configuration) do
          create(
            :service_configuration,
            :confirmation_email_subject,
            service_id: service.service_id,
            deployment_environment: deployment_environment
          )
        end

        context 'when reference number is enabled' do
          let(:params) { { reference_number: '1' } }
          let(:default_value) do
            I18n.t(
              'default_values.reference_number.confirmation_email_subject',
              service_name: service.service_name
            )
          end

          it 'updates the service configuration with reference number default value' do
            reference_number_updater.create_or_update!
            service_configuration.reload

            expect(
              service_configuration.decrypt_value
            ).to eq(default_value)
          end
        end

        context 'when reference number is disabled' do
          let(:default_value) do
            I18n.t(
              'default_values.confirmation_email_subject',
              service_name: service.service_name
            )
          end

          it 'updates the service configuration with default value' do
            reference_number_updater.create_or_update!
            service_configuration.reload

            expect(
              service_configuration.decrypt_value
            ).to eq(default_value)
          end
        end
      end

      context 'confirmation email body' do
        let!(:service_configuration) do
          create(
            :service_configuration,
            :confirmation_email_body,
            service_id: service.service_id,
            deployment_environment: deployment_environment
          )
        end

        context 'when reference number is enabled' do
          let(:params) { { reference_number: '1' } }
          let(:default_value) do
            I18n.t(
              'default_values.reference_number.confirmation_email_body',
              service_name: service.service_name
            )
          end

          it 'updates the service configuration with reference number default value' do
            reference_number_updater.create_or_update!
            service_configuration.reload

            expect(
              service_configuration.decrypt_value
            ).to eq(default_value)
          end
        end

        context 'when reference number is disabled' do
          let(:default_value) do
            I18n.t(
              'default_values.confirmation_email_body',
              service_name: service.service_name
            )
          end

          it 'updates the service configuration with default value' do
            reference_number_updater.create_or_update!
            service_configuration.reload

            expect(
              service_configuration.decrypt_value
            ).to eq(default_value)
          end
        end
      end

      context 'service email subject' do
        let!(:service_configuration) do
          create(
            :service_configuration,
            :service_email_subject,
            service_id: service.service_id,
            deployment_environment: deployment_environment
          )
        end

        context 'when reference number is enabled' do
          let(:params) { { reference_number: '1' } }
          let(:default_value) do
            I18n.t(
              'default_values.reference_number.service_email_subject',
              service_name: service.service_name
            )
          end

          it 'updates the service configuration with reference number default value' do
            reference_number_updater.create_or_update!
            service_configuration.reload

            expect(
              service_configuration.decrypt_value
            ).to eq(default_value)
          end
        end

        context 'when reference number is disabled' do
          let(:default_value) do
            I18n.t(
              'default_values.service_email_subject',
              service_name: service.service_name
            )
          end

          it 'updates the service configuration with default value' do
            reference_number_updater.create_or_update!
            service_configuration.reload

            expect(
              service_configuration.decrypt_value
            ).to eq(default_value)
          end
        end
      end

      context 'service email body' do
        let!(:service_configuration) do
          create(
            :service_configuration,
            :service_email_body,
            service_id: service.service_id,
            deployment_environment: deployment_environment
          )
        end

        context 'when reference number is enabled' do
          let(:params) { { reference_number: '1' } }
          let(:default_value) do
            I18n.t(
              'default_values.reference_number.service_email_body',
              service_name: service.service_name
            )
          end

          it 'updates the service configuration with reference number default value' do
            reference_number_updater.create_or_update!
            service_configuration.reload

            expect(
              service_configuration.decrypt_value
            ).to eq(default_value)
          end
        end

        context 'when reference number is disabled' do
          let(:default_value) do
            I18n.t(
              'default_values.service_email_body',
              service_name: service.service_name
            )
          end

          it 'updates the service configuration with default value' do
            reference_number_updater.create_or_update!
            service_configuration.reload

            expect(
              service_configuration.decrypt_value
            ).to eq(default_value)
          end
        end
      end

      context 'service email pdf heading' do
        let!(:service_configuration) do
          create(
            :service_configuration,
            :service_email_pdf_heading,
            service_id: service.service_id,
            deployment_environment: deployment_environment
          )
        end

        context 'when reference number is enabled' do
          let(:params) { { reference_number: '1' } }
          let(:default_value) do
            I18n.t(
              'default_values.reference_number.service_email_pdf_heading',
              service_name: service.service_name
            )
          end

          it 'updates the service configuration with reference number default value' do
            reference_number_updater.create_or_update!
            service_configuration.reload

            expect(
              service_configuration.decrypt_value
            ).to eq(default_value)
          end
        end

        context 'when reference number is disabled' do
          let(:default_value) do
            I18n.t(
              'default_values.service_email_pdf_heading',
              service_name: service.service_name
            )
          end

          it 'updates the service configuration with default value' do
            reference_number_updater.create_or_update!
            service_configuration.reload

            expect(
              service_configuration.decrypt_value
            ).to eq(default_value)
          end
        end
      end
    end

    context 'in dev environment' do
      let(:deployment_environment) { 'dev' }
      it_behaves_like 'reference number service configuration'
    end

    context 'in production environment' do
      let(:deployment_environment) { 'production' }
      it_behaves_like 'reference number service configuration'
    end
  end
end
