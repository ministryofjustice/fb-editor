RSpec.describe  DomainValidator do
  let(:subject) { EmailSettings.new(params) }
  let(:service_id) { SecureRandom.uuid }

  describe '#validate' do
    before do
      subject.validate
    end

    shared_examples 'a domain validation' do
      context 'when email domain is on the allow list' do
        Rails.application.config.allowed_domains.each do |domain|
          let(:params) do
            {
              service_email_output: "hello@#{domain}",
              deployment_environment: environment
            }
          end

          it "returns valid for '#{domain}'" do
            expect(subject).to be_valid
          end
        end
      end

      context 'when email domain is not on the allow list' do
        let(:params) do
          {
            service_email_output: 'hello@notvalid.gov.uk',
            deployment_environment: environment
          }
        end

        it 'returns invalid' do
          expect(subject).to_not be_valid
        end

        it 'returns an error message' do
          expect(subject.errors.full_messages).to include(I18n.t('activemodel.errors.models.email_settings.domain_invalid'))
        end
      end
    end

    context 'when in dev' do
      it_behaves_like 'a domain validation' do
        let(:environment) { 'dev' }
      end
    end

    context 'when in production' do
      it_behaves_like 'a domain validation' do
        let(:environment) { 'production' }
      end
    end
  end
end
