RSpec.describe ConfirmationEmailSettingsUpdater do
  subject(:confirmation_email_settings_updater) do
    described_class.new(
      confirmation_email_settings: ConfirmationEmailSettings.new(
        params.merge(
          service: service,
          deployment_environment: 'dev'
        )
      ),
      service: service
    )
  end
  let(:params) { {} }
  let(:default_body) do
    I18n.t(
      'default_values.confirmation_email_body',
      service_name: service.service_name
    )
  end
  let(:default_subject) do
    I18n.t(
      'default_values.confirmation_email_subject',
      service_name: service.service_name
    )
  end

  describe '#create_or_update' do
    context 'confirmation_email_component_id' do
      context 'when confirmation_email_component_id exists in the db' do
        let!(:service_configuration) do
          create(
            :service_configuration,
            :dev,
            :confirmation_email_component_id,
            service_id: service.service_id
          )
        end

        context 'when a user updates the value' do
          let(:params) do
            {
              confirmation_email_component_id: 'email_question_1'
            }
          end

          it 'updates the service configuration subject' do
            confirmation_email_settings_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:confirmation_email_component_id])
          end
        end
      end

      context 'when confirmation email component id does not exist in the db' do
        let(:service_configuration) do
          ServiceConfiguration.find_by(
            service_id: service.service_id,
            name: 'CONFIRMATION_EMAIL_COMPONENT_ID'
          )
        end

        context 'when an user adds the value' do
          let(:params) do
            {
              confirmation_email_component_id: 'email_question_1'
            }
          end
          before { confirmation_email_settings_updater.create_or_update! }

          it 'updates the service configuration subject' do
            expect(service_configuration).to be_persisted
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:confirmation_email_component_id])
          end
        end
      end
    end

    context 'confirmation email subject' do
      context 'when confirmation email subject exists in the db' do
        let!(:service_configuration) do
          create(
            :service_configuration,
            :dev,
            :confirmation_email_subject,
            service_id: service.service_id
          )
        end

        context 'when a user updates the value' do
          let(:params) do
            {
              confirmation_email_subject: 'You got mail'
            }
          end

          it 'updates the service configuration subject' do
            confirmation_email_settings_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:confirmation_email_subject])
          end
        end

        context 'when a user removes the value' do
          let(:params) do
            {
              confirmation_email_subject: ''
            }
          end

          it 'shows the default subject' do
            confirmation_email_settings_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq(default_subject)
          end
        end
      end

      context 'when confirmation email subject does not exist in db' do
        let(:service_configuration) do
          ServiceConfiguration.find_by(
            service_id: service.service_id,
            name: 'CONFIRMATION_EMAIL_SUBJECT'
          )
        end

        context 'when an user adds a value' do
          let(:params) do
            {
              confirmation_email_subject: 'You got mail'
            }
          end

          before do
            confirmation_email_settings_updater.create_or_update!
          end

          it 'creates the service configuration subject' do
            expect(service_configuration).to be_persisted
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:confirmation_email_subject])
          end
        end

        context 'when a user removes the value' do
          let(:params) do
            {
              confirmation_email_subject: ''
            }
          end
          before { confirmation_email_settings_updater.create_or_update! }

          it 'shows the default subject' do
            expect(service_configuration).to be_persisted
            expect(
              service_configuration.decrypt_value
            ).to eq(default_subject)
          end
        end
      end
    end

    context 'confirmation email body' do
      context 'when email body exists in the db' do
        let!(:service_configuration) do
          create(
            :service_configuration,
            :dev,
            :confirmation_email_body,
            service_id: service.service_id
          )
        end

        context 'when an user updates the value' do
          let(:params) do
            {
              confirmation_email_body: 'God help us, we’re in the hands of engineers.'
            }
          end

          it 'updates the service configuration body' do
            confirmation_email_settings_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:confirmation_email_body])
          end
        end

        context 'when a user removes the value' do
          let(:params) do
            {
              confirmation_email_body: ''
            }
          end

          it 'shows the default body' do
            confirmation_email_settings_updater.create_or_update!
            service_configuration.reload
            expect(
              service_configuration.decrypt_value
            ).to eq(default_body)
          end
        end
      end

      context 'when email body does not exist in db' do
        let(:service_configuration) do
          ServiceConfiguration.find_by(
            service_id: service.service_id,
            name: 'CONFIRMATION_EMAIL_BODY'
          )
        end

        context 'when a user adds a value' do
          let(:params) do
            {
              confirmation_email_body: "Let's not count our poultry before it's incubated."
            }
          end

          before do
            confirmation_email_settings_updater.create_or_update!
          end

          it 'creates the service configuration body' do
            expect(service_configuration).to be_persisted
            expect(
              service_configuration.decrypt_value
            ).to eq(params[:confirmation_email_body])
          end
        end

        context 'when a user removes the value' do
          let(:params) do
            {
              confirmation_email_body: ''
            }
          end
          before { confirmation_email_settings_updater.create_or_update! }

          it 'shows the default subject' do
            expect(service_configuration).to be_persisted
            expect(
              service_configuration.decrypt_value
            ).to eq(default_body)
          end
        end
      end
    end
  end
end
