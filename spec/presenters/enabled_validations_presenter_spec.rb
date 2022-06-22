RSpec.describe EnabledValidationsPresenter do
  subject(:enabled_validations_presenter) { described_class.new(component) }

  describe '#enabled_list' do
    context 'when not a text component' do
      let(:component) { service.find_page_by_url('your-age').components.first }
      let(:expected_validations_list) { %w[minimum maximum] }

      before do
        allow(Rails.application.config).to receive(
          :enabled_validations
        ).and_return(%w[minimum maximum])
      end

      it 'keeps the component validation names' do
        expect(subject.enabled_list).to eq(expected_validations_list)
      end
    end

    context 'when a text component that supports string validations' do
      let(:component) { service.find_page_by_url('name').components.first }
      let(:expected_validations_list) { %w[max_string_length min_string_length] }

      before do
        allow(Rails.application.config).to receive(
          :enabled_validations
        ).and_return(%w[max_length min_length max_word min_word])
        allow(component).to receive(:supported_validations).and_return(
          %w[min_length max_length min_word max_word pattern format]
        )
      end

      it 'maps the component validation names to *_string_length' do
        expect(subject.enabled_list).to eq(expected_validations_list)
      end
    end
  end
end
