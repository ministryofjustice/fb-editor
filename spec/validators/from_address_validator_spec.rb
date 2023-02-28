RSpec.describe  FromAddressValidator do
  let(:subject) { ConfirmationEmailSettings.new(params) }
  let(:service_id) { SecureRandom.uuid }
  let(:from_address) { FromAddress.new({ email: }) }

  describe '#validate' do
    before do
      subject.validate
    end

    shared_examples 'a domain validation' do
      context 'when email domain is on the allow list' do
        Rails.application.config.allowed_domains.each do |domain|
          let(:email) { "hello@#{domain}" }
          let(:params) do
            {
              from_address:,
              deployment_environment: environment
            }
          end

          it "returns valid for '#{domain}'" do
            expect(subject).to be_valid
          end
        end
      end

      context 'when email domain is not on the allow list' do
        let(:email) { 'hello@notvalid.gov.uk' }
        let(:params) do
          {
            from_address:,
            deployment_environment: environment
          }
        end

        it 'returns invalid' do
          expect(subject).to_not be_valid
        end

        it 'returns an error message' do
          expect(subject.errors.full_messages).to include(/#{I18n.t('activemodel.errors.models.reply_to.domain_invalid')}/)
        end
      end
    end

    shared_examples 'a valid email format' do
      context 'when the email format is valid' do
        let(:email) { 'hello@digital.justice.gov.uk' }
        let(:params) do
          {
            from_address:,
            deployment_environment: environment
          }
        end

        it 'returns valid' do
          expect(subject).to be_valid
        end
      end

      context 'when the email format is invalid' do
        let(:email) { 'I am not a valid email' }
        let(:params) do
          {
            from_address:,
            deployment_environment: environment
          }
        end

        it 'returns invalid' do
          expect(subject).to_not be_valid
        end

        it 'returns an error message' do
          expect(subject.errors.first.type).to include(I18n.t('activemodel.errors.models.from_address.invalid'))
        end
      end
    end

    context 'when in dev' do
      it_behaves_like 'a domain validation' do
        let(:environment) { 'dev' }
      end

      it_behaves_like 'a valid email format' do
        let(:environment) { 'dev' }
      end
    end

    context 'when in production' do
      it_behaves_like 'a domain validation' do
        let(:environment) { 'production' }
      end

      it_behaves_like 'a valid email format' do
        let(:environment) { 'production' }
      end
    end
  end
end
