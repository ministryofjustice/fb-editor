RSpec.describe NumberValidator do
  let(:subject) { ComponentValidations::MinimumValidation.new(validation_params) }
  let(:latest_metadata) { metadata_fixture(:version) }
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
  let(:page_uuid) { '54ccc6cd-60c0-4749-947b-a97af1bc0aa2' } # your age
  let(:component_uuid) { 'b3014ef8-546a-4a35-9669-c5c1667e86d7' }
  let(:validator) { 'minimum' }
  let(:status) { 'enabled' }

  describe '#validate' do
    before { subject.validate }

    context 'when not a number' do
      %w[centuries . $ # % , 1.a 2.b].each do |invalid_answer|
        let(:value) { invalid_answer }

        it "returns invalid for '#{invalid_answer}'" do
          expect(subject).to_not be_valid
        end
      end
    end

    context 'when is a number' do
      %w[1 1.1 100].each do |valid_answer|
        let(:value) { valid_answer }

        it "returns valid for '#{valid_answer}'" do
          expect(subject).to be_valid
        end
      end
    end
  end
end
