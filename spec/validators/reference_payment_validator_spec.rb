RSpec.describe  ReferencePaymentValidator do
  let(:subject) { ReferencePaymentSettings.new(params) }
  let(:service_id) { SecureRandom.uuid }
  let(:correct_url) { I18n.t('activemodel.errors.models.reference_payment_settings.link_start_with') }

  describe '#validate' do
    before do
      subject.validate
    end
    context 'when payment link is enabled' do
      context 'when reference number is disabled' do
        let(:params) do
          {
            reference_number: '0',
            payment_link: '1',
            payment_link_url: 'gov.uk'
          }
        end

        it 'returns invalid' do
          expect(subject).to_not be_valid
        end

        it 'returns an error message' do
          expect(subject.errors.full_messages).to include(I18n.t('activemodel.errors.models.reference_payment_settings.reference_number_disabled'))
        end
      end

      context 'when reference number is enabled' do
        let(:params) do
          {
            service_id: service_id,
            reference_number: '1',
            payment_link: '1',
            payment_link_url: correct_url
          }
        end

        it 'returns valid' do
          expect(subject).to be_valid
        end
      end

      context 'when payment link is missing' do
        let(:params) do
          {
            reference_number: '1',
            payment_link: '1',
            payment_link_url: ''
          }
        end

        it 'returns invalid' do
          expect(subject).to_not be_valid
        end

        it 'returns an error message' do
          expect(subject.errors.full_messages).to include(I18n.t('activemodel.errors.models.reference_payment_settings.missing_payment_link'))
        end
      end

      context 'when payment link url is invalid' do
        let(:params) do
          {
            reference_number: '1',
            payment_link: '1',
            payment_link_url: 'dummy.link'
          }
        end

        it 'returns invalid' do
          expect(subject).to_not be_valid
        end

        it 'returns an error message' do
          expect(subject.errors.full_messages).to include(
            I18n.t(
              'activemodel.errors.models.reference_payment_settings.invalid_payment_url',
              link_start_with: I18n.t('activemodel.errors.models.reference_payment_settings.link_start_with')
            )
          )
        end
      end

      context 'when reference number is disabled and payment link is missing' do
        let(:params) do
          {
            service_id: service_id,
            reference_number: '0',
            payment_link: '1',
            payment_link_url: ''
          }
        end

        it 'should display two error messages' do
          expect(subject.errors.full_messages).to include(I18n.t('activemodel.errors.models.reference_payment_settings.reference_number_disabled'))
          expect(subject.errors.full_messages).to include(I18n.t('activemodel.errors.models.reference_payment_settings.missing_payment_link'))
        end
      end
    end

    context 'when payment link is disabled' do
      context 'when payment url is present' do
        let(:params) do
          {
            service_id: service_id,
            reference_number: '1',
            payment_link: '0',
            payment_link_url: correct_url
          }
        end

        it 'returns valid' do
          expect(subject).to be_valid
        end
      end
    end
  end
end
