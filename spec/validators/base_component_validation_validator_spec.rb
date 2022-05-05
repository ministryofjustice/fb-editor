RSpec.describe BaseComponentValidationValidator do
  let(:subject) { BaseComponentValidation.new(validation_params) }
  let(:latest_metadata) { metadata_fixture(:version) }
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }
  let(:validation_params) do
    {
      service: service,
      page_uuid: page_uuid,
      component_uuid: component_uuid,
      validator: validator,
      status: status,
      value: value
    }
  end
  let(:page_uuid) { '54ccc6cd-60c0-4749-947b-a97af1bc0aa2' } # your age
  let(:component_uuid) { 'b3014ef8-546a-4a35-9669-c5c1667e86d7' }
  let(:validator) { 'minimum' }
  let(:status) { 'enabled' }
  let(:value) { '5' }

  describe '#validate' do
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
          'some-non-existent-validator is not valid for number component'
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
        expect_any_instance_of(BaseComponentValidationValidator).not_to receive(:validate)
        expect(subject.errors).to be_empty
      end
    end

    context 'when component status is enabled' do
      context 'when value is present' do
        it 'it returns valid' do
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
        expect_any_instance_of(BaseComponentValidationValidator).not_to receive(:validate)
        expect(subject.errors).to be_empty
      end
    end
  end
end
