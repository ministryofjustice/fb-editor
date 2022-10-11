RSpec.describe EmailDomainValidator do
  let(:validator) { EmailDomainValidator.new }
  let(:email) { 'buck.rogers@digital.justice.gov.uk' }

  describe '#allowed?' do
    context 'when email is allowed' do
      it 'returns true' do
        expect(validator.allowed?(email)).to be_truthy
      end
    end

    context 'when email is not allowed' do
      let(:email) { 'buck.rogers@gmail.com' }

      it 'returns false' do
        expect(validator.allowed?(email)).to be_falsey
      end
    end

    context 'when email is blank' do
      let(:email) { '' }

      it 'returns nil' do
        expect(validator.allowed?(email)).to be_nil
      end
    end
  end
end
