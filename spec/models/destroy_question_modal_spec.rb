RSpec.describe DestroyQuestionModal do
  subject(:destroy_question_modal) do
    described_class.new(
      service: service,
      page: page,
      question: question
    )
  end
  let(:service_metadata) { metadata_fixture(:branching_2) }

  describe '#to_partial_path' do
    let(:question) { page.components.first }
    subject(:partial) do
      destroy_question_modal.to_partial_path
    end

    context 'when there is a branch that depends on the question' do
      let(:page) { service.find_page_by_url('page-b') }

      it 'returns can not delete the question modal' do
        expect(partial).to eq('api/questions/cannot_delete_modal')
      end
    end

    context 'when there is not a branch that depends on the question' do
      let(:page) { service.find_page_by_url('page-d') }

      it 'returns default delete question modal' do
        expect(partial).to eq('api/questions/destroy_message_modal')
      end
    end
  end
end
