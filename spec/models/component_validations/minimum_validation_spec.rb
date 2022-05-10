RSpec.describe 'MinimumValidation' do
  let(:subject) { MinimumValidation.new(validation_params) }
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

  it_behaves_like 'a base component validation'

  context 'validating a number' do
    context 'when enabled and value is present' do
      it 'validates the number value' do
        expect_any_instance_of(NumberValidator).to receive(:validate)
        subject.valid?
      end

      context 'when value is not a number' do
        let(:value) { 'i am not number!' }
        let(:expected_error) { 'Minimum answer value needs to be a number' }

        before { subject.valid? }

        it 'is invalid' do
          expect(subject).to be_invalid
        end

        it 'surfaces the error correctly' do
          expect(subject.errors.full_messages.first).to eq(expected_error)
        end
      end

      context 'when value is not present' do
        let(:value) { nil }
        let(:expected_error) { 'Enter an answer for Minimum answer value' }

        before { subject.valid? }

        it 'is invalid' do
          expect(subject).to be_invalid
        end

        it 'surfaces the error correctly' do
          expect(subject.errors.full_messages.first).to eq(expected_error)
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

  describe '#to_metadata' do
    let(:expected_metadata) { { 'minimum' => '5' } }

    it 'returns default metadata' do
      expect(subject.to_metadata).to eq(expected_metadata)
    end
  end
end
