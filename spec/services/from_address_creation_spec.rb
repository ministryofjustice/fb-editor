RSpec.describe FromAddressCreation, type: :model do
  subject(:from_address_creation) do
    described_class.new(params)
  end
  let(:params) do
    {
      from_address: from_address,
      from_address_params: from_address_params,
      email_service: email_service
    }
  end

  let(:email) { FromAddress::DEFAULT_EMAIL_FROM }
  let(:service_id) { SecureRandom.uuid }
  let(:from_address) { FromAddress.find_or_initialize_by(service_id: service_id) }
  let(:from_address_params) { { email: email } }
  let(:email_service) { double }

  describe '#save' do
    context 'with default email' do
      it 'saves successfully' do
        from_address_creation.save
        expect(from_address).to be_persisted
      end

      it 'doesn\'t call AWS SES' do
        expect(from_address_creation).not_to receive(:verify_email)
        from_address_creation.save
      end
    end

    context 'with the user inputed and non default email' do
      let(:email) { 'falkor@justice.gov.uk' }

      context 'Writing on the database' do
        let(:email_service) { double(get_email_identity: nil, create_email_identity: true) }
        before do
          from_address_creation.save
        end

        it 'saves sucessfully' do
          expect(from_address.reload.email_address).to eq(email)
        end

        it 'updates status to pending' do
          expect(from_address.reload.status).to eq('pending')
        end
      end

      context 'when creating a new identity' do
        let(:email_service) { EmailService::Adapters::AwsSesClient.new }
        before do
          allow(email_service).to receive(:get_email_identity).and_return(nil)
        end

        it 'works makes AWS call and creates identity' do
          expect_any_instance_of(Aws::SESV2::Client).to receive(:create_email_identity).with(email_identity: email)
          from_address_creation.save
        end
      end
    end

    context 'if it fails to save' do
      before do
        allow(from_address).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'returns false' do
        expect(from_address_creation.save).to be_falsey
      end
    end

    context 'when sending enabled is true in aws' do
      let(:email_identity) { double(sending_enabled: true) }
      let(:email) { 'atreyu@justice.gov.uk' }

      before do
        create(:from_address, :pending, service_id: service_id, email: 'mothertheresa@justice.gov.uk')
        allow(from_address_creation).to receive(:email_identity).and_return(email_identity)
        allow(email_service).to receive(:get_email_identity).and_return(double)
        from_address_creation.save
      end

      it 'sets the from address status to verified' do
        expect(from_address.reload.status).to eq('verified')
      end

      it 'sets the correct email address' do
        expect(from_address.reload.email_address).to eq(email)
      end
    end

    context 'when sending enabled is false but from address record is verified' do
      let(:email_identity) { double(sending_enabled: false) }
      let(:email) { 'artax@justice.gov.uk' }

      before do
        create(:from_address, :verified, service_id: service_id, email: email)
        allow(from_address_creation).to receive(:email_identity).and_return(email_identity)
        allow(email_service).to receive(:get_email_identity).and_return(double)
        from_address_creation.save
      end

      it 'sets the from address status to default' do
        expect(from_address.reload.status).to eq('default')
      end
    end

    context 'when the email is blank' do
      let(:email) { '' }
      it 'saves the default email address to the DB' do
        from_address_creation.save

        expect(from_address).to be_persisted
        expect(from_address.reload.email_address).to eq(FromAddress::DEFAULT_EMAIL_FROM)
      end
    end

    context 'when cannot reach AWS SES' do
      let(:email) { 'marie_curie@justice.gov.uk' }
      before do
        allow(email_service).to receive(:get_email_identity).and_raise(EmailServiceError)
        from_address_creation.save
      end

      it 'set correct error message' do
        expect(from_address.errors.full_messages.first).to eq(I18n.t('activemodel.errors.models.from_address.email_service_error'))
      end
    end
  end
end
