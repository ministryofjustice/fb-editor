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

    context 'branching questions' do
      before do
        allow(destroy_question_modal).to receive(:used_in_confirmation_email?).and_return(false)
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

    context 'confirmation email questions' do
      let(:service_metadata) { metadata_fixture(:branching_12) }
      let(:service_configuration) do
        create(
          :service_configuration,
          name: 'CONFIRMATION_EMAIL_COMPONENT_ID',
          value: 'multi2_email_1',
          deployment_environment: 'dev'
        )
      end

      before do
        allow(destroy_question_modal).to receive(:confirmation_email_component_id).and_return(service_configuration)
      end

      context 'when confirmation email depends on a question' do
        let(:page) { service.find_page_by_url('multi2') }

        it 'returns can not delete the question modal' do
          expect(partial).to eq('api/questions/cannot_delete_confirmation_email_modal')
        end
      end

      context 'when a confirmation email does not depend on a question' do
        let(:page) { service.find_page_by_url('email') }

        it 'returns default delete question modal' do
          expect(partial).to eq('api/questions/destroy_message_modal')
        end
      end

      context 'when confirmation email has not been set' do
        let(:page) { service.find_page_by_url('email') }

        before do
          allow(destroy_question_modal).to receive(:confirmation_email_component_id).and_return(nil)
        end

        it 'returns default delete question modal' do
          expect(partial).to eq('api/questions/destroy_message_modal')
        end
      end
    end
  end
end
