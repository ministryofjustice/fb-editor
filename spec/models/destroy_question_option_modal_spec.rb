RSpec.describe DestroyQuestionOptionModal do
  subject(:destroy_question_option_modal) do
    described_class.new(
      service:,
      page:,
      question:,
      option:
    )
  end
  let(:service_metadata) { metadata_fixture(:branching_2) }

  describe '#to_partial_path' do
    let(:question) { page.components.first }
    subject(:partial) do
      destroy_question_option_modal.to_partial_path
    end

    context 'when there is a branch that relies on the option' do
      let(:service_metadata) { metadata_fixture(:branching_2) }
      let(:page) { service.find_page_by_url('page-b') }
      let(:option) { question.items.first }

      it 'returns can not delete option modal' do
        expect(partial).to eq('api/question_options/delete_option_used_for_branching_modal')
      end
    end

    context 'when there is not a branch that depends on the option' do
      let(:page) { service.find_page_by_url('page-b') }
      let(:option) { question.items.last }

      it 'returns default delete option modal' do
        expect(partial).to eq('api/question_options/delete_option_modal')
      end
    end

    context 'when there is conditional content that depends on the option' do
      let(:service_metadata) { metadata_fixture(:conditional_content_2) }
      let(:page) { service.find_page_by_url('marmite') }
      let(:option) { question.items.first }

      it 'returns the delete conditional content modal' do
        expect(partial).to eq('api/question_options/delete_option_used_for_conditional_content_modal')
      end
    end

    context 'when there is conditional content and branching that depends on the option' do
      let(:service_metadata) { metadata_fixture(:conditional_content_2) }
      let(:page) { service.find_page_by_url('coffee') }
      let(:option) { question.items.first }

      it 'returns the delete conditional content modal' do
        expect(partial).to eq('api/question_options/delete_option_used_for_conditional_content_modal')
      end
    end
  end
end
