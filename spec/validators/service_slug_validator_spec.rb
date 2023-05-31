RSpec.describe ServiceSlugValidator do
  let(:subject) { FormNameUrlSettings.new(params) }
  let(:service_id) { SecureRandom.uuid }

  describe '#validate' do
    before do
      subject.validate
    end

    context 'SERVICE_SLUG' do
      context 'when service slug already exists' do
        let!(:existing_service_configuration) do
          create(
            :service_configuration,
            :dev,
            :service_slug,
            service_id: SecureRandom.uuid
          )
        end

        before do
          allow_any_instance_of(
            ServiceSlugValidator
          ).to receive(:all_service_slugs).and_return(
            [existing_service_configuration.decrypt_value]
          )
        end

        let(:params) do
          {
            service_slug: 'eat-slugs-malfoy',
            service_name: 'Form name'
          }
        end

        it 'returns invalid' do
          expect(subject).to_not be_valid
        end
      end

      context 'when service slug does not exist' do
        let(:params) do
          {
            service_slug: 'eat-slugs-malfoy',
            service_name: 'Form name'
          }
        end

        it 'returns valid' do
          expect(subject).to be_valid
        end
      end
    end

    context 'PREVIOUS_SERVICE_SLUG' do
      context 'when previous service slug exists' do
        let!(:existing_service_configuration) do
          create(
            :service_configuration,
            :dev,
            :previous_service_slug,
            service_id: SecureRandom.uuid
          )
        end

        before do
          allow_any_instance_of(
            ServiceSlugValidator
          ).to receive(:all_service_slugs).and_return(
            [existing_service_configuration.decrypt_value]
          )
        end

        let(:params) do
          {
            service_slug: 'slug-life',
            service_name: 'Form name'
          }
        end

        it 'returns invalid' do
          expect(subject).to_not be_valid
        end
      end
    end
  end
end
