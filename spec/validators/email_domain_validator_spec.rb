RSpec.describe EmailDomainValidator do
  let(:subject) { FromAddress.new(params) }
  let(:params) do
    {
      service_id: SecureRandom.uuid,
      email: email
    }
  end
  let(:email) { 'buck.rogers@digital.justice.gov.uk' }

  describe '#validate' do
    before do
      subject.validate
    end

    context 'when email is allowed' do
      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'when email is not allowed' do
      let(:email) { 'buck.rogers@gmail.com' }

      it 'is not valid' do
        expect(subject).to_not be_valid
      end

      it 'returns the correct error message' do
        expect(subject.errors.full_messages).to eq([I18n.t(
          'activemodel.errors.models.from_address.invalid_domain'
        )])
      end
    end

    context 'when email is blank' do
      let(:email) { '' }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end
  end
end
