RSpec.describe FromAddressCreation, type: :model do
  subject(:from_address_creation) do
    described_class.new(params)
  end
  let(:params) do
    {
      from_address: from_address,
      email_service: email_service
    }
  end

  let(:email) { FromAddress::DEFAULT_EMAIL_FROM }
  let(:service_id) { SecureRandom.uuid }
  let(:from_address) { FromAddress.find_or_initialize_by(from_address_params.merge(service_id: service_id)) }
  let(:from_address_params) { { email: email } }
  let(:email_service) { double }
  let(:old_email) { FromAddress.find_or_initialize_by({ email: 'old@email.com', service_id: service_id }) }

  describe '#save' do
    before do
      allow(FromAddress).to receive(:find_by).and_return(old_email)
    end

    context 'with default email' do
      it 'saves successfully' do
        from_address_creation.save
        expect(from_address).to be_persisted
      end

      it 'saves the default status' do
        from_address_creation.save
        expect(from_address.reload.status).to eq('default')
      end
    end

    context 'with email on allow list' do
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

        it 'makes AWS call and creates identity' do
          expect_any_instance_of(Aws::SESV2::Client).to receive(:create_email_identity).with(email_identity: email)
          from_address_creation.save
        end
      end
    end

    context 'email is already saved' do
      let(:email) { 'peanut@justice.gov.uk' }
      before do
        allow(FromAddress).to receive(:find_by).and_return(FromAddress.find_or_initialize_by({ email: email, service_id: service_id }))
      end

      context 'Writing on the database' do
        let(:email_service) { double(get_email_identity: nil, create_email_identity: true) }
        before do
          # verify and save the from address to match the mocked equality check
          from_address.verified!
          from_address.save!
          from_address_creation.save
        end

        it 'does not change email address' do
          expect(from_address.reload.email_address).to eq(email)
        end

        it 'does not change status' do
          expect(from_address.reload.status).to eq('verified')
        end
        it 'does not make AWS call' do
          expect_any_instance_of(Aws::SESV2::Client).to_not receive(:create_email_identity)
          from_address_creation.save
        end
      end
    end

    context 'with email not on allow list' do
      let(:email) { 'galadriel@valinor.me' }

      context 'Writing on the database' do
        let(:email_service) { double(get_email_identity: nil) }
        before do
          from_address_creation.save
        end

        it 'saves sucessfully' do
          expect(from_address.reload.email_address).to eq(email)
        end

        it 'updates status to pending' do
          expect(from_address.reload.status).to eq('pending')
        end
        it 'does not make AWS call' do
          expect_any_instance_of(Aws::SESV2::Client).to_not receive(:create_email_identity)
          from_address_creation.save
        end
      end
    end

    context 'if it fails to save' do
      before do
        allow(from_address).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
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

    context 'when sending enabled is false in aws' do
      # this happens when the email verification link expires and the identity status changes to 'unverified' in AWS
      let(:email_identity) { double(get_email_identity: true, sending_enabled: false) }
      let(:email) { 'atreyu@justice.gov.uk' }

      before do
        create(:from_address, :pending, service_id: service_id, email: 'atreyu@justice.gov.uk')
        allow(from_address_creation).to receive(:email_identity).and_return(email_identity)
        allow(email_service).to receive(:get_email_identity).and_return(double)
        expect(email_service).to receive(:delete_email_identity).with(email).and_return(double(successful?: true))
        expect(email_service).to receive(:create_email_identity).with(email).and_return(double(successful?: true))
        from_address_creation.save
      end

      it 'sets the from address status to pending' do
        expect(from_address.reload.status).to eq('pending')
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

    context 'when email is invalid' do
      let(:email) { 'bob' }

      it 'does not make AWS call' do
        expect(from_address_creation).to_not receive(:verify_email)
      end
    end
  end
end
