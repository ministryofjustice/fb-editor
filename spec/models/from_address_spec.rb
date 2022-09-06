require 'rails_helper'

RSpec.describe FromAddress, type: :model do
  subject(:from_address) do
    described_class.new(params)
  end

  before do
    subject.validate
  end

  let(:params) do
    {
      service_id: SecureRandom.uuid,
      email: email
    }
  end
  let(:default_email) { 'moj-forms@digital.justice.gov.uk' }

  describe '#email_address' do
    context 'when it is a valid email' do
      let(:email) { 'bob@gmail.com' }

      it 'is valid' do
        expect(from_address).to be_valid
      end

      it 'returns the decrypted email value' do
        expect(from_address.email_address).to eq(email)
      end
    end

    context 'when email is blank' do
      let(:email) { '' }

      it 'is valid' do
        # when the user submits an empty string, the default email is saved
        expect(from_address).to be_valid
      end
    end

    invalid_emails = [
      "'hello@gmail.com'",
      'first.last@sub.do,com',
      'first.last',
      'gabriela.brimmer@-xample.com',
      '"first"last"@gmail.org',
      'plainaddress',
      '#@%^%#$@#$@#.com',
      '@example.com',
      'Joe Smith <email@example.com>',
      'email.example.com',
      'email@example@example.com',
      'あいうえお@example.com',
      'email@example.com (Joe Smith)',
      'email@-example.com',
      'email@example..com',
      'empress wu@outlook.com',
      'hello@'
    ]

    invalid_emails.each do |invalid_email|
      context "when email is invalid: '#{invalid_email}'" do
        let(:email) { invalid_email }

        it 'returns invalid' do
          expect(from_address).to_not be_valid
        end

        it "returns the original value: '#{invalid_email}'" do
          expect(from_address.email_address).to eq(invalid_email)
        end
      end
    end
  end

  context 'encrypting and decrypting emails' do
    before do
      create(:from_address, service_id: service_id, email: email).save
    end
    let(:service_id) { SecureRandom.uuid }
    let(:email) { 'hello@gmail.com' }
    let(:created_from_address) { FromAddress.find_by(service_id: service_id) }

    describe '#before_save' do
      context 'encrypting email' do
        it 'saves an encrypted email' do
          expect(created_from_address.email).not_to eq('hello@gmail.com')
        end
      end
    end

    describe '#decrypt_email' do
      context 'decrypting email' do
        it 'decrypts an email from the db' do
          expect(created_from_address.decrypt_email).to eq('hello@gmail.com')
        end
      end
    end
  end
end
