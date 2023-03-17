RSpec.shared_examples 'a number validation' do
  context 'validating a number' do
    context 'when enabled and value is present' do
      it 'validates the number value' do
        expect_any_instance_of(NumberValidator).to receive(:validate)
        subject.valid?
      end

      context 'when value is not a number' do
        let(:value) { 'i am not number!' }

        before { subject.valid? }

        it 'is invalid' do
          expect(subject).to be_invalid
        end

        it 'surfaces the error correctly' do
          expect(subject.errors.full_messages[0]).to include(expected_number_error)
        end
      end

      context 'when value is not present' do
        let(:value) { nil }

        before { subject.valid? }

        it 'is invalid' do
          expect(subject).to be_invalid
        end

        it 'surfaces the error correctly' do
          expect(subject.errors.full_messages[0]).to include(expected_blank_error)
        end
      end
    end

    context 'when status attribute is not present' do
      let(:status) { nil }

      it 'does not validate the number value' do
        expect_any_instance_of(NumberValidator).not_to receive(:validate)
        subject.valid?
      end
    end
  end
end
