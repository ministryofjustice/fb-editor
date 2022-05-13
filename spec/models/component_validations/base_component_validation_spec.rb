RSpec.describe 'BaseComponentValidation' do
  subject { BaseComponentValidation.new(validation_params) }
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

  describe '#enabled?' do
    context 'when status is present' do
      it 'returns truthy' do
        expect(subject.enabled?).to be_truthy
      end
    end

    context 'when status not present' do
      context 'when validation has been previously enabled' do
        let(:latest_metadata) do
          meta = metadata_fixture(:version)
          meta['pages'][4]['components'][0]['validation'] = validation
          meta
        end
        let(:validation) do
          {
            'required' => true,
            'number' => true,
            'minimum' => '2'
          }
        end

        it 'returns truthy' do
          expect(subject.enabled?).to be_truthy
        end
      end

      context 'when validation has not been previously enabled' do
        let(:status) { nil }

        it 'returns falsey' do
          expect(subject.enabled?).to be_falsey
        end
      end
    end
  end

  describe '#run_validation?' do
    context 'when enabled' do
      context 'when value attribute is present' do
        it 'returns truthy' do
          expect(subject.run_validation?).to be_truthy
        end
      end

      context 'when value attribute is not present' do
        let(:value) { nil }

        it 'returns falsey' do
          expect(subject.run_validation?).to be_falsey
        end
      end
    end

    context 'when status is not present' do
      let(:status) { nil }

      it 'returns falsey' do
        expect(subject.run_validation?).to be_falsey
      end
    end
  end

  describe '#component_type' do
    it 'returns the component type' do
      expect(subject.component_type).to eq('number')
    end
  end

  describe '#main_value' do
    context 'when value is present' do
      it 'returns the value initialised in the model' do
        expect(subject.main_value).to eq('5')
      end
    end

    context 'when value is not present and validation previously enabled' do
      let(:latest_metadata) do
        meta = metadata_fixture(:version)
        meta['pages'][4]['components'][0]['validation'] = validation
        meta
      end
      let(:validation) do
        {
          'required' => true,
          'number' => true,
          'minimum' => '2'
        }
      end
      let(:value) { nil }

      it 'returns the previously set value' do
        expect(subject.main_value).to eq('2')
      end
    end
  end
end
