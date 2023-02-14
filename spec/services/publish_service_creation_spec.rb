RSpec.describe PublishServiceCreation, type: :model do
  subject(:publish_service_creation) do
    described_class.new(
      attributes.merge(
        service_id:,
        version_id:,
        user_id:
      )
    )
  end
  let(:service_id) { service.service_id }
  let(:version_id) { SecureRandom.uuid }
  let!(:user_id) { create(:user).id }

  describe '#service_configuration' do
    let(:attributes) { {} }

    context 'when configuration exists' do
      let!(:username_config) do
        create(
          :service_configuration,
          :dev,
          :username,
          value: 'x-wing',
          service_id:
        )
      end

      it 'returns the value decoded' do
        expect(
          publish_service_creation.service_configuration(
            name: ServiceConfiguration::BASIC_AUTH_USER,
            deployment_environment: 'dev'
          )
        ).to eq('x-wing')
      end
    end

    context 'when configuration does not exist' do
      it 'returns nil' do
        expect(
          publish_service_creation.service_configuration(
            name: :username,
            deployment_environment: 'dev'
          )
        ).to be_nil
      end
    end
  end

  describe '#existing_authentication?' do
    let(:attributes) { {} }

    context 'when configuration exists' do
      let!(:username_config) do
        create(:service_configuration, :dev, :username, service_id:)
      end

      it 'returns true' do
        expect(
          publish_service_creation.existing_authentication?(
            deployment_environment: 'dev'
          )
        ).to be_truthy
      end
    end

    context 'when configuration does not exist' do
      context 'when there is a publish service' do
        let!(:publish_service) do
          create(:publish_service, :dev, :completed, service_id:)
        end

        it 'returns false' do
          expect(
            publish_service_creation.existing_authentication?(
              deployment_environment: 'dev'
            )
          ).to be_falsey
        end
      end

      context 'when no publish service exists' do
        it 'returns true' do
          expect(
            publish_service_creation.existing_authentication?(
              deployment_environment: 'dev'
            )
          ).to be_truthy
        end
      end
    end
  end

  describe '#save' do
    context 'when invalid' do
      context 'when require authentication' do
        let(:attributes) { { require_authentication: '1' } }

        it 'returns false' do
          expect(publish_service_creation.save).to be_falsey
        end

        it 'requires service_id' do
          should_not allow_values(nil, '').for(:service_id)
        end

        it 'requires username' do
          should_not allow_values(nil, '').for(:username)
        end

        it 'requires password' do
          should_not allow_values(nil, '').for(:password)
        end

        it 'validates min length for username' do
          should_not allow_values('a').for(:username)
        end

        it 'validates min length for password' do
          should_not allow_values('a').for(:password)
        end

        it 'validates max length for username' do
          should_not allow_values('a' * 51).for(:username)
        end

        it 'validates max length for password' do
          should_not allow_values('a' * 51).for(:password)
        end
      end

      context 'when does not require authentication' do
        let(:attributes) { { require_authentication: '0' } }

        it 'accepts blank username' do
          should allow_values(nil, '').for(:username)
        end

        it 'accepts blank password' do
          should allow_values(nil, '').for(:password)
        end
      end

      context 'when publish service is invalid' do
        let(:attributes) { { require_authentication: '0' } }

        it 'raises active record validation' do
          expect {
            publish_service_creation.save
          }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end

    context 'when require authentication' do
      context 'when existing username and password' do
        let!(:username_config) do
          create(
            :service_configuration,
            :dev,
            :username,
            value: 'executor',
            service_id:
          )
        end
        let!(:password_config) do
          create(
            :service_configuration,
            :dev,
            :password,
            value: 'vader-ship',
            service_id:
          )
        end
        let(:attributes) do
          {
            deployment_environment: 'dev',
            username: 'executor',
            password: 'vader-ship',
            require_authentication: '1'
          }
        end
        before { publish_service_creation.save }

        it 'returns true' do
          expect(publish_service_creation.save).to be_truthy
        end

        it 'updates username in base64' do
          expect(username_config.reload.decrypt_value).to eq('executor')
        end

        it 'updates password in base64' do
          expect(password_config.reload.decrypt_value).to eq('vader-ship')
        end
      end

      context 'when not existing username and password' do
        let(:attributes) do
          {
            deployment_environment: 'dev',
            username: 'executor',
            password: 'vader-ship',
            require_authentication: '1'
          }
        end
        let(:username_config) do
          ServiceConfiguration.where(
            service_id:,
            deployment_environment: attributes.fetch(:deployment_environment),
            name: 'BASIC_AUTH_USER'
          ).first
        end
        let(:password_config) do
          ServiceConfiguration.where(
            service_id:,
            deployment_environment: attributes.fetch(:deployment_environment),
            name: 'BASIC_AUTH_PASS'
          ).first
        end

        before { publish_service_creation.save }

        it 'creates username in base64' do
          expect(username_config).to be_present
          expect(username_config.decrypt_value).to eq('executor')
        end

        it 'creates password in base64' do
          expect(password_config).to be_present
          expect(password_config.reload.decrypt_value).to eq('vader-ship')
        end
      end
    end

    context 'when do not require authentication' do
      context 'when not existing username and password' do
      end

      context 'when existing username and password' do
        let!(:username_config) do
          create(:service_configuration, :production, :username, service_id:)
        end
        let!(:password_config) do
          create(:service_configuration, :production, :password, service_id:)
        end
        let(:attributes) do
          {
            deployment_environment: 'production',
            username: 'something',
            password: 'other-something',
            require_authentication: '0'
          }
        end
        before { 2.times { publish_service_creation.save } }

        it 'deletes username service configuration' do
          expect(ServiceConfiguration.exists?(username_config.id)).to be_falsey
        end

        it 'deletes the password service configuration' do
          expect(ServiceConfiguration.exists?(password_config.id)).to be_falsey
        end
      end
    end
  end

  describe '#no_service_output?' do
    %w[dev production].each do |environment|
      context "when #{environment} environment" do
        let(:attributes) { { deployment_environment: environment } }

        context 'when send by email is enabled' do
          before do
            create(:submission_setting, environment.to_sym, :send_email, service_id:)
          end

          context 'when service email output exists' do
            before do
              create(:service_configuration, environment.to_sym, :service_email_output, service_id:)
            end

            it 'should return falsey' do
              expect(publish_service_creation.no_service_output?).to be_falsey
            end
          end

          context 'when there is no service email output' do
            it 'should return truthy' do
              expect(publish_service_creation.no_service_output?).to be_truthy
            end
          end
        end

        context 'when send by email is disabled (does not exist)' do
          it 'should return truthy' do
            expect(publish_service_creation.no_service_output?).to be_truthy
          end
        end
      end
    end
  end

  context '#service_email_from' do
    %w[dev production].each do |environment|
      context "when #{environment} environment" do
        let(:attributes) { { deployment_environment: environment } }
        let(:email) { 'princess.layer-cake@digital.justice.gov.uk' }

        context 'when service configuration email from does not exist' do
          context 'and the from address email has been changed' do
            before do
              create(:from_address, service_id:, email:)
              publish_service_creation.save
            end

            it 'saves the email to the database' do
              service_config = ServiceConfiguration.find_by(service_id:, name: 'SERVICE_EMAIL_FROM')
              expect(service_config.decrypt_value).to eq(email)
            end
          end

          context 'and the from address has not been changed' do
            before do
              publish_service_creation.save
            end

            it 'saves the email to the database' do
              service_config = ServiceConfiguration.find_by(service_id:, name: 'SERVICE_EMAIL_FROM')
              expect(service_config.decrypt_value).to eq(FromAddress::DEFAULT_EMAIL_FROM)
            end
          end
        end

        context 'when service configuration email from exists' do
          before do
            create(:from_address, service_id:, email:)
            create(:service_configuration, environment.to_sym, :service_email_from, service_id:, value: 'darth.baker@justice.gov.uk')

            publish_service_creation.save
          end

          it 'overwrites the previous service configuration email' do
            service_config = ServiceConfiguration.find_by(service_id:, name: 'SERVICE_EMAIL_FROM')
            expect(service_config.decrypt_value).to eq(email)
          end
        end
      end
    end
  end
end
