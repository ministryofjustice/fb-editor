RSpec.describe ContentSubstitutor do
  subject(:content_substitutor) do
    described_class.new(
      reference_number_enabled: reference_number_enabled,
      service_name: service_name
    )
  end
  let(:reference_number_enabled) { true }
  let(:service_name) { 'The Substitutor!' }

  describe '#confirmation_email_subject' do
    context 'when reference number is enabled' do
      let(:content) do
        I18n.t('default_values.reference_number_subject')
      end

      it 'returns the correct content' do
        expect(content_substitutor.confirmation_email_subject).to include(content)
      end
    end

    context 'when reference number is disabled' do
      let(:reference_number_enabled) { false }
      let(:content) { '{{reference_number_placeholder}}' }

      it 'returns the correct content' do
        expect(content_substitutor.confirmation_email_subject).to_not include(content)
      end
    end
  end

  describe '#confirmation_email_body' do
    context 'when reference number is enabled' do
      let(:content) do
        I18n.t('default_values.reference_number_sentence')
      end

      it 'returns the correct content' do
        expect(content_substitutor.confirmation_email_body).to include(content)
      end
    end

    context 'when reference number is disabled' do
      let(:reference_number_enabled) { false }
      let(:content) { '{{reference_number_placeholder}}' }

      it 'returns the correct content' do
        expect(content_substitutor.confirmation_email_body).to_not include(content)
      end
    end
  end

  describe '#service_email_subject' do
    context 'when reference number is enabled' do
      let(:content) do
        I18n.t('default_values.reference_number_subject')
      end

      it 'returns the correct content' do
        expect(content_substitutor.service_email_subject).to include(content)
      end
    end

    context 'when reference number is disabled' do
      let(:reference_number_enabled) { false }
      let(:content) { '{{reference_number_placeholder}}' }

      it 'returns the correct content' do
        expect(content_substitutor.service_email_subject).to_not include(content)
      end
    end
  end

  describe '#service_email_body' do
    context 'when reference number is enabled' do
      let(:content) do
        I18n.t('default_values.reference_number_sentence')
      end

      it 'returns the correct content' do
        expect(content_substitutor.service_email_body).to include(content)
      end
    end

    context 'when reference number is disabled' do
      let(:reference_number_enabled) { false }
      let(:content) { '{{reference_number_placeholder}}' }

      it 'returns the correct content' do
        expect(content_substitutor.service_email_body).to_not include(content)
      end
    end
  end

  describe '#service_email_pdf_heading' do
    context 'when reference number is enabled' do
      let(:content) do
        I18n.t('default_values.reference_number_subject')
      end

      it 'returns the correct content' do
        expect(content_substitutor.service_email_pdf_heading).to include(content)
      end
    end

    context 'when reference number is disabled' do
      let(:reference_number_enabled) { false }
      let(:content) { '{{reference_number_placeholder}}' }

      it 'returns the correct content' do
        expect(content_substitutor.service_email_pdf_heading).to_not include(content)
      end
    end
  end

  describe '#assign' do
    context 'when setting exists' do
      let(:content) { I18n.t('default_values.reference_number_subject') }
      context 'when reference number is enabled' do
        it 'returns the correct content' do
          expect(content_substitutor.assign('confirmation_email_subject')).to include(content)
        end
      end

      context 'when reference number is disabled' do
        let(:reference_number_enabled) { false }

        it 'returns the correct content' do
          expect(content_substitutor.assign('confirmation_email_subject')).to_not include(content)
        end
      end
    end

    context 'when setting does not exist' do
      it 'returns nil' do
        expect(content_substitutor.assign('blah_blah')).to be_nil
      end
    end
  end
end
