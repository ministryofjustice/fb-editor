RSpec.describe ReferenceNumberUpdater do
  subject(:reference_number_updater) do
    described_class.new(
      reference_number_settings: reference_number_settings,
      service: service
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
    context 'reference number' do
      context 'when reference_number exists in the db' do
        let(:params) { { reference_number: '0' } }

        before do
          create(
            :service_configuration,
            :reference_number,
            service_id: service.service_id,
            deployment_environment: 'production'
          )
          create(
            :service_configuration,
            :reference_number,
            service_id: service.service_id,
            deployment_environment: 'dev'
          )

          reference_number_updater.create_or_update!
        end

        context 'when a user unticked the box' do
          it 'removes the records from the database' do
            expect(
              ServiceConfiguration.where(
                service_id: service.service_id,
                name: 'REFERENCE_NUMBER'
              )
            ).to be_empty
          end
        end
      end

      context 'when reference_number doesn\'t exist in the db' do
        context 'when a user ticks the box' do
          let(:params) { { reference_number: '1' } }

          it 'creates the submission settings' do
            reference_number_updater.create_or_update!

            expect(
              ServiceConfiguration.find_by(
                service_id: service.service_id,
                name: 'REFERENCE_NUMBER',
                deployment_environment: 'dev'
              )
            ).to be_present

            expect(
              ServiceConfiguration.find_by(
                service_id: service.service_id,
                name: 'REFERENCE_NUMBER',
                deployment_environment: 'production'
              )
            ).to be_present
          end
        end

        context 'when a user does not tick the box' do
          let(:params) { { reference_number: '0' } }

          it 'creates the submission settings' do
            reference_number_updater.create_or_update!

            expect(
              ServiceConfiguration.where(
                service_id: service.service_id,
                name: 'REFERENCE_NUMBER'
              )
            ).to be_empty
          end
        end
      end
    end

    context 'configs with defaults' do
      before do
        reference_number_updater.create_or_update!
      end

      %w[
          CONFIRMATION_EMAIL_SUBJECT
          CONFIRMATION_EMAIL_BODY
          SERVICE_EMAIL_SUBJECT
          SERVICE_EMAIL_BODY
          SERVICE_EMAIL_PDF_HEADING
      ].each do |config|

        context 'when reference number is enabled' do
          let(:params) { { reference_number: '1' } }
          let(:content) { I18n.t("default_values.#{config.downcase}", service_name: service.service_name) }

          it 'updates the service configuration with reference number default value' do
            expect(
              ServiceConfiguration.find_by(
                service_id: service.service_id,
                name: config,
                deployment_environment: 'dev'
              ).decrypt_value
            ).to eq(content)

            expect(
              ServiceConfiguration.find_by(
                service_id: service.service_id,
                name: config,
                deployment_environment: 'production'
              ).decrypt_value
            ).to eq(content)
          end
        end

        context 'when reference number is disabled' do
          let(:params) { { reference_number: '0' } }
          let(:placeholder) { BaseEmailSettings::REFERENCE_NUMBER_PLACEHOLDER }

          it 'updates the service configuration with reference number default value' do
            expect(
              ServiceConfiguration.find_by(
                service_id: service.service_id,
                name: config,
                deployment_environment: 'dev'
              ).decrypt_value
            ).to_not include(placeholder)

            expect(
              ServiceConfiguration.find_by(
                service_id: service.service_id,
                name: config,
                deployment_environment: 'production'
              ).decrypt_value
            ).to_not include(placeholder)
          end
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
            'default_values.confirmation_email_body',
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
            'default_values.service_email_subject',
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
            'default_values.service_email_body',
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
            'default_values.service_email_pdf_heading',
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
end
