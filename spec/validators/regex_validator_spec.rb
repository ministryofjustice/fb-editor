RSpec.describe RegexValidator do
  let(:subject) { PatternValidation.new(validation_params) }
  let(:latest_metadata) { metadata_fixture(:regex) }
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }
  let(:validation_params) do
    {
      service:,
      page_uuid:,
      component_uuid:,
      validator:,
      status:,
      value:
    }
  end
  let(:page_uuid) { '121183c6-7ee8-4b5d-b74a-dacee8aa4cd5' } # single question regex
  let(:component_uuid) { '375b6aa9-6548-4d71-ab69-6ff6c68a9d2f' } # expect a good regex
  let(:validator) { 'pattern' }
  let(:status) { 'enabled' }
  let(:value) { '\\D+' }

  describe '#validate' do
    before { subject.validate }

    context 'when a valid regex' do
      it 'returns valid' do
        expect(subject).to be_valid
      end
    end

    context 'when not a valid regex' do
      let(:value) { '[01]?[0-9]|2[0-3]):[0-5][0-9]' }

      it 'returns invalid' do
        expect(subject).to_not be_valid
      end

      it 'returns an error message' do
        expect(subject.errors.full_messages).to include(I18n.t('activemodel.errors.models.string_regex_pattern.invalid'))
      end
    end

    context 'when it contains delimiter at the beginning' do
      let(:value) { '/[a-z]' }

      it 'returns invalid' do
        expect(subject).to_not be_valid
      end

      it 'returns an error message' do
        expect(subject.errors.full_messages).to include(I18n.t('activemodel.errors.models.string_regex_pattern.remove_delimiter'))
      end
    end

    context 'when it contains delimiter at the end' do
      let(:value) { '[a-z]/' }

      it 'returns invalid' do
        expect(subject).to_not be_valid
      end

      it 'returns an error message' do
        expect(subject.errors.full_messages).to include(I18n.t('activemodel.errors.models.string_regex_pattern.remove_delimiter'))
      end
    end

    context 'when it contains options' do
      context 'for insensitive case' do
        let(:value) { '[a-z]/i' }

        it 'returns invalid' do
          expect(subject).to_not be_valid
        end

        it 'returns an error message' do
          expect(subject.errors.full_messages).to include(I18n.t('activemodel.errors.models.string_regex_pattern.remove_options'))
        end
      end

      context 'for multiline regex' do
        let(:value) { '[a-z].[0-9]{3}/m' }

        it 'returns invalid' do
          expect(subject).to_not be_valid
        end

        it 'returns an error message' do
          expect(subject.errors.full_messages).to include(I18n.t('activemodel.errors.models.string_regex_pattern.remove_options'))
        end
      end

      context 'for extended regex' do
        let(:value) { '\D{5}/x' }

        it 'returns invalid' do
          expect(subject).to_not be_valid
        end

        it 'returns an error message' do
          expect(subject.errors.full_messages).to include(I18n.t('activemodel.errors.models.string_regex_pattern.remove_options'))
        end
      end

      context 'for several options' do
        let(:value) { '\d{5}/ix' }

        it 'returns invalid' do
          expect(subject).to_not be_valid
        end

        it 'returns an error message' do
          expect(subject.errors.full_messages).to include(I18n.t('activemodel.errors.models.string_regex_pattern.remove_options'))
        end
      end
    end

    context 'when it contains several issues' do
      let(:value) { '/[01]?[0-9]|2[0-3]):[0-5][0-9]/i' }

      it 'returns invalid' do
        expect(subject).to_not be_valid
      end

      it 'shows all error messages' do
        expect(subject.errors.full_messages).to include(I18n.t('activemodel.errors.models.string_regex_pattern.invalid'))
        expect(subject.errors.full_messages).to include(I18n.t('activemodel.errors.models.string_regex_pattern.remove_options'))
        expect(subject.errors.full_messages).to include(I18n.t('activemodel.errors.models.string_regex_pattern.remove_delimiter'))
      end
    end
  end
end
