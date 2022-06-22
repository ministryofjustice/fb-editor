RSpec.shared_examples 'a base component validation' do
  context 'validations' do
    before { subject.validate }

    context 'when component type exists' do
      context 'when validator exists for component' do
        it 'it returns valid' do
          expect(subject).to be_valid
        end
      end

      context 'when a text component and a string length validator' do
        let(:validator) { 'max_string_length' }
        let(:page_uuid) { 'e8708909-922e-4eaf-87a5-096f7a713fcb' } # How well do you know star wars?
        let(:component_uuid) { 'fda1e5a1-ed5f-49c9-a943-dc930a520984' }

        it 'returns valid' do
          expect(subject).to be_valid
        end
      end

      context 'when a textarea component and a string length validator' do
        let(:validator) { 'min_string_length' }
        let(:page_uuid) { 'b8335af2-6642-4e2f-8192-0dd12279eec7' } # family hobbies
        let(:component_uuid) { '9bf39533-dbd2-45ed-b2b8-9b29bf5fe9e8' }

        it 'returns valid' do
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
