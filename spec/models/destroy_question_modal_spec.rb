RSpec.describe DestroyQuestionModal do
  subject(:destroy_question_modal) do
    described_class.new(
      service:,
      page:,
      question:
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
        allow(destroy_question_modal).to receive(:used_for_confirmation_email?).and_return(false)
      end

      context 'when there is a branch that depends on the question' do
        let(:page) { service.find_page_by_url('page-b') }

        it 'returns can not delete the question modal' do
          expect(partial).to eq('api/questions/delete_question_used_for_branching_modal')
        end
      end

      context 'when there is not a branch that depends on the question' do
        let(:page) { service.find_page_by_url('page-d') }

        it 'returns default delete question modal' do
          expect(partial).to eq('api/questions/delete_question_modal')
        end
      end
    end

    context 'conditional content questions' do
      let(:service_metadata) { metadata_fixture(:conditional_content_2) }
      let(:question) { page.components.first }

      context 'when there is conditional content that depends on the question' do
        let(:page) { service.find_page_by_url('multiple') }

        it 'returns the delete conditional content modal' do
          skip('awaiting updated presenter') unless ENV['CONDITIONAL_CONTENT'] == 'enabled'
          expect(partial).to eq('api/questions/delete_question_used_for_conditional_content_modal')
        end
      end

      context 'when there is not conditional content that depends on the question' do
        let(:page) { service.find_page_by_url('multiple') }
        let(:question) { page.components[2] }

        it 'returns the default delete modal' do
          skip('awaiting updated presenter') unless ENV['CONDITIONAL_CONTENT'] == 'enabled'
          expect(partial).to eq('api/questions/delete_question_modal')
        end
      end

      context 'when there is conditional content and branching that depends on the question' do
        let(:page) { service.find_page_by_url('multiple') }
        let(:question) { page.components.last }

        it 'returns the delete conditional content modal' do
          skip('awaiting updated presenter') unless ENV['CONDITIONAL_CONTENT'] == 'enabled'
          expect(partial).to eq('api/questions/delete_question_used_for_conditional_content_modal')
        end
      end
    end

    context 'confirmation email questions' do
      let(:service_metadata) { metadata_fixture(:branching_12) }
      let(:default_destroy_partial) { 'api/questions/delete_question_modal' }
      let(:service_configuration) do
        create(
          :service_configuration,
          name: 'CONFIRMATION_EMAIL_COMPONENT_ID',
          value:,
          deployment_environment: 'dev'
        ).decrypt_value
      end
      let(:page) { service.find_page_by_url('multi2') }

      context 'when confirmation email setting is checked in dev' do
        let(:value) { 'multi2_email_1' }

        context 'and confirmation email depends on a question' do
          before do
            create(:submission_setting, :dev, :send_confirmation_email, service_id: service.service_id)
            allow(destroy_question_modal).to receive(:confirmation_email_component_ids).and_return([service_configuration])
          end

          it 'returns can not delete the question modal' do
            expect(partial).to eq('api/questions/delete_question_used_for_confirmation_email_modal')
          end
        end

        context 'and confirmation email does not depend on a question' do
          let(:value) { 'email_not_used' }

          before do
            create(:submission_setting, :dev, send_confirmation_email: false, service_id: service.service_id)
          end

          it 'returns default delete partial' do
            expect(partial).to eq(default_destroy_partial)
          end
        end
      end

      context 'when CONFIRMATION_EMAIL_COMPONENT_ID is present in both environments' do
        let(:value) { 'multi2_email_1' }
        let(:service_configuration_production) do
          create(
            :service_configuration,
            name: 'CONFIRMATION_EMAIL_COMPONENT_ID',
            value: 'email-component-production',
            deployment_environment: 'production'
          ).decrypt_value
        end

        before do
          allow(destroy_question_modal).to receive(:confirmation_email_component_ids).and_return([service_configuration, service_configuration_production])
        end

        context 'and confirmation email is checked in dev only' do
          before do
            create(:submission_setting, :dev, :send_confirmation_email, service_id: service.service_id)
          end

          it 'returns can not delete the question modal' do
            expect(partial).to eq('api/questions/delete_question_used_for_confirmation_email_modal')
          end
        end

        context 'and confirmation email is not checked in either environment' do
          before do
            create(:submission_setting, :dev, send_confirmation_email: nil, service_id: service.service_id)
            create(:submission_setting, :production, send_confirmation_email: nil, service_id: service.service_id)
          end

          it 'returns default delete partial' do
            expect(partial).to eq(default_destroy_partial)
          end
        end
      end

      context 'when a confirmation email does not depend on a question' do
        let(:page) { service.find_page_by_url('email') }

        it 'returns default delete partial' do
          expect(partial).to eq(default_destroy_partial)
        end
      end

      context 'when confirmation email has not been checked' do
        before do
          create(:submission_setting, :dev, send_confirmation_email: nil, service_id: service.service_id)
          create(:submission_setting, :production, send_confirmation_email: nil, service_id: service.service_id)
        end

        it 'returns default delete partial' do
          expect(partial).to eq(default_destroy_partial)
        end
      end
    end
  end
end
