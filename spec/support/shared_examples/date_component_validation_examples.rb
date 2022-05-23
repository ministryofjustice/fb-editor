RSpec.shared_examples 'a date validation' do
  context 'validations' do
    context 'when fields are present' do
      it 'validates using the DateValidator' do
        expect_any_instance_of(DateValidator).to receive(:validate)
        subject.valid?
      end
    end

    context 'when fields are not present' do
      let(:day) { nil }

      it 'returns invalid' do
        subject.valid?
        expect(subject).to_not be_valid
      end
    end
  end

  context 'attribute answers' do
    context 'when attributes are present' do
      describe '#answered_day' do
        it 'returns the passed in attribute' do
          expect(subject.answered_day).to eq(day)
        end
      end

      describe '#answered_month' do
        it 'returns the passed in attribute' do
          expect(subject.answered_month).to eq(month)
        end
      end

      describe '#answered_year' do
        it 'returns the passed in attribute' do
          expect(subject.answered_year).to eq(year)
        end
      end
    end

    context 'when attributes not present and validation has been previously set' do
      let(:day) { nil }
      let(:month) { nil }
      let(:year) { nil }
      let(:latest_metadata) do
        meta = metadata_fixture(:version)
        meta['pages'][7]['components'][0]['validation'] = component_validation
        meta
      end

      describe '#answered_day' do
        it 'returns the previously set attribute field' do
          expect(subject.answered_day).to eq(previously_set_fields['day'])
        end
      end

      describe '#answered_month' do
        it 'returns the previously set attribute field' do
          expect(subject.answered_month).to eq(previously_set_fields['month'])
        end
      end

      describe '#answered_year' do
        it 'returns the previously set attribute field' do
          expect(subject.answered_year).to eq(previously_set_fields['year'])
        end
      end
    end
  end
end
