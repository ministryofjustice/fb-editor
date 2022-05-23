RSpec.shared_examples 'a base component validation' do
  context 'validations' do
    before { subject.validate }

    context 'when component type exists' do
      context 'when validator exists for component' do
        it 'it returns valid' do
          expect(subject).to be_valid
        end
      end

      context 'when validator does not exist for component' do
        let(:validator) { 'some-non-existent-validator' }
        let(:expected_error) do
          "some-non-existent-validator is not valid for #{subject.component_type} component"
        end

        it 'it returns invalid' do
          expect(subject).to be_invalid
        end

        it 'surfaces the error' do
          expect(subject.errors.full_messages.first).to eq(expected_error)
        end
      end
    end

    context 'when component status is enabled' do
      context 'when value is present' do
        it 'it returns valid' do
          expect(subject).to be_valid
        end
      end

      context 'when component type is a date' do
        let(:validator) { 'date_before' }
        let(:page_uuid) { '7806cd64-0c05-450e-ba6f-2325c8b22d46' } # holiday
        let(:component_uuid) { 'f16b7e7b-fbfa-4e41-a413-ee7eaf6063a6' }

        it 'does not try to validate presence' do
          expect(subject).to be_valid
        end
      end

      context 'when value is not present' do
        let(:value) { nil }

        it 'it returns invalid' do
          expect(subject).to be_invalid
        end
      end
    end

    context 'when component status is not present' do
      let(:status) { nil }

      it 'does not attempt to validate anything' do
        expect(subject.errors).to be_empty
      end
    end
  end
end
