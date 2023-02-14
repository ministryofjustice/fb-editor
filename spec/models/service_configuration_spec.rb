require 'rails_helper'

RSpec.describe ServiceConfiguration, type: :model do
  describe '#valid?' do
    context 'service_id' do
      it 'do not allow blank' do
        should_not allow_values('').for(:service_id)
      end
    end

    context 'name' do
      it 'do not allow blank' do
        should_not allow_values('').for(:name)
      end
    end

    context 'value' do
      it 'do not allow blank' do
        should_not allow_values('').for(:value)
      end
    end

    context 'deployment environment' do
      it 'allow dev and production' do
        should allow_values('dev', 'production').for(:deployment_environment)
      end

      it 'do not allow enything else' do
        should_not allow_values(
          nil, '', 'something-else', 'staging', 'live', 'test'
        ).for(:deployment_environment)
      end
    end
  end

  describe '#secrets?' do
    context 'when is a secret' do
      let(:service_configuration) do
        build(
          :service_configuration,
          name: 'ENCODED_PRIVATE_KEY'
        )
      end

      it 'returns true' do
        expect(service_configuration).to be_secrets
      end
    end

    context 'when is a config map' do
      let(:service_configuration) do
        build(
          :service_configuration,
          name: 'ENCODED_PUBLIC_KEY'
        )
      end

      it 'returns false' do
        expect(service_configuration).to_not be_secrets
      end
    end
  end

  describe '#do_not_send_submission?' do
    subject(:service_configuration) do
      described_class.new(name: 'SERVICE_EMAIL_OUTPUT')
    end

    context 'when submission setting exists' do
      let!(:submission_setting) do
        create(
          :submission_setting,
          :dev,
          service_id: service.service_id,
          send_email:
        )
      end

      context 'when send email flag is true' do
        let(:send_email) { true }

        %w[
          SERVICE_EMAIL_OUTPUT
          SERVICE_EMAIL_FROM
          SERVICE_EMAIL_SUBJECT
          SERVICE_EMAIL_BODY
          SERVICE_EMAIL_PDF_HEADING
          SERVICE_EMAIL_PDF_SUBHEADING
        ].each do |configuration|
          context "when configuration is #{configuration}" do
            let(:service_configuration) do
              described_class.new(
                name: configuration,
                service_id: service.service_id,
                deployment_environment: 'dev'
              )
            end

            it 'returns false' do
              expect(service_configuration.do_not_send_submission?).to be_falsey
            end
          end
        end

        %w[OTHER_ENV_VARS ENCODED_PRIVATE_KEY].each do |configuration|
          context "when configuration is #{configuration}" do
            let(:service_configuration) do
              described_class.new(
                name: configuration,
                service_id: service.service_id,
                deployment_environment: 'dev'
              )
            end

            it 'returns false' do
              expect(service_configuration.do_not_send_submission?).to be_falsey
            end
          end
        end
      end

      context 'when send email flag is false' do
        let(:send_email) { false }

        %w[OTHER_ENV_VARS ENCODED_PRIVATE_KEY].each do |configuration|
          context "when configuration is #{configuration}" do
            let(:service_configuration) do
              described_class.new(
                name: configuration,
                service_id: service.service_id,
                deployment_environment: 'dev'
              )
            end

            it 'returns false' do
              expect(service_configuration.do_not_send_submission?).to be_falsey
            end
          end
        end
      end
    end

    context 'when submission setting does not exist' do
      it 'returns true' do
        expect(service_configuration.do_not_send_submission?).to be_truthy
      end
    end
  end

  describe '#do_not_send_confirmation_email?' do
    subject(:service_configuration) do
      described_class.new(name: 'CONFIRMATION_EMAIL_COMPONENT_ID')
    end

    context 'when confirmation email setting exists' do
      let!(:submission_setting) do
        create(
          :submission_setting,
          :dev,
          service_id: service.service_id,
          send_confirmation_email:
        )
      end

      context 'when send confirmation email flag is true' do
        let(:send_confirmation_email) { true }

        %w[
          CONFIRMATION_EMAIL_COMPONENT_ID
          SERVICE_EMAIL_FROM
          CONFIRMATION_EMAIL_SUBJECT
          CONFIRMATION_EMAIL_BODY
        ].each do |configuration|
          context "when configuration is #{configuration}" do
            let(:service_configuration) do
              described_class.new(
                name: configuration,
                service_id: service.service_id,
                deployment_environment: 'dev'
              )
            end

            it 'returns false' do
              expect(service_configuration.do_not_send_confirmation_email?).to be_falsey
            end
          end
        end

        %w[OTHER_ENV_VARS ENCODED_PRIVATE_KEY].each do |configuration|
          context "when configuration is #{configuration}" do
            let(:service_configuration) do
              described_class.new(
                name: configuration,
                service_id: service.service_id,
                deployment_environment: 'dev'
              )
            end

            it 'returns false' do
              expect(service_configuration.do_not_send_confirmation_email?).to be_falsey
            end
          end
        end
      end

      context 'when send confirmation email flag is false' do
        let(:send_confirmation_email) { false }

        %w[OTHER_ENV_VARS ENCODED_PRIVATE_KEY].each do |configuration|
          context "when configuration is #{configuration}" do
            let(:service_configuration) do
              described_class.new(
                name: configuration,
                service_id: service.service_id,
                deployment_environment: 'dev'
              )
            end

            it 'returns false' do
              expect(service_configuration.do_not_send_confirmation_email?).to be_falsey
            end
          end
        end
      end
    end

    context 'when submission setting does not exist' do
      it 'returns true' do
        expect(service_configuration.do_not_send_confirmation_email?).to be_truthy
      end
    end
  end

  context 'encrypting and decrypting values' do
    let(:service_configuration) do
      create(:service_configuration, :dev, :username, value: 'r2d2')
    end

    describe '#before_save' do
      context 'encrypting value' do
        it 'saves a encrypted value' do
          expect(service_configuration.value).not_to eq('r2d2')
        end
      end
    end

    describe '#decrypt_value' do
      context 'decrypting value' do
        it 'decrypts a value from the db' do
          expect(service_configuration.decrypt_value).to eq('r2d2')
        end
      end
    end

    describe '#encode64' do
      context 'base64 encoded value' do
        it 'base64 encodes the value' do
          expect(service_configuration.encode64).to eq(Base64.strict_encode64('r2d2'))
        end
      end
    end

    describe '#config_map_value' do
      context 'when name is PAYMENT_LINK' do
        let(:payment_link) { 'some-payment-link' }
        let(:service_configuration) do
          create(:service_configuration, :dev, :payment_link_url, value: payment_link)
        end
        let(:expected_payment_link) do
          "#{payment_link}#{ServiceConfiguration::REFERENCE_PARAM}"
        end

        it 'should return the decrypted value with the reference param' do
          expect(service_configuration.config_map_value).to eq(expected_payment_link)
        end
      end

      context 'when CONFIRMATION_EMAIL_BODY' do
        let(:service_configuration) do
          create(
            :service_configuration,
            :dev,
            :confirmation_email_body,
            value: "You need to pay\n\r\nPay at {{payment_link}}.\nAt some point"
          )
        end
        let(:expected_confirmation_email_body) do
          'You need to pay<br /><br /><br />Pay at <a href=\"{{payment_link}}\">{{payment_link}}</a>.<br />At some point'
        end

        it 'should insert the a tag with the payment link placeholder' do
          expect(service_configuration.config_map_value).to eq(expected_confirmation_email_body)
        end
      end

      context 'when SERVICE_EMAIL_BODY' do
        let(:service_configuration) do
          create(
            :service_configuration,
            :dev,
            :service_email_body,
            value: "Some email\n\r\nbody saying some\nthings"
          )
        end
        let(:expected_service_email_body) do
          'Some email<br /><br /><br />body saying some<br />things'
        end

        it 'should insert the a tag with the payment link placeholder' do
          expect(service_configuration.config_map_value).to eq(expected_service_email_body)
        end
      end

      context 'when name is not PAYMENT_LINK or CONFIRMATION_EMAIL_BODY' do
        let(:service_configuration) do
          create(:service_configuration, :dev, :confirmation_email_subject, value: 'subject')
        end

        it 'should return just the decrypted value' do
          expect(service_configuration.config_map_value).to eq('subject')
        end
      end
    end
  end
end
