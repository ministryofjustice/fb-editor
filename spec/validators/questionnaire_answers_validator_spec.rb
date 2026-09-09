RSpec.describe QuestionnaireAnswersValidator do
  subject(:validator) { described_class.new(answers) }

  describe '#valid?' do
    context 'when answers are nil' do
      let(:answers) { nil }

      it 'returns false' do
        expect(validator).to_not be_valid
      end
    end

    context 'when answers are present' do
      context 'when it is an experiment' do
        let(:answers) do
          {
            new_form_reason: Questionnaire::GetStartedForm::EXPERIMENT
          }
        end

        it 'returns true' do
          expect(validator).to be_valid
        end
      end

      context 'when it is NOT an experiment' do
        let(:answers) do
          {
            new_form_reason: Questionnaire::GetStartedForm::BUILDING
          }
        end

        context 'when required fields are missing' do
          it 'returns false' do
            expect(validator).to_not be_valid
          end
        end

        context 'when all required fields are present' do
          let(:answers) do
            {
              new_form_reason: Questionnaire::GetStartedForm::BUILDING,
              estimated_page_count: '10',
              estimated_first_year_submissions_count: '100',
              submission_delivery_method: 'email'
            }
          end

          it 'returns true' do
            expect(validator).to be_valid
          end
        end

        context 'when some required fields are missing' do
          let(:answers) do
            {
              new_form_reason: Questionnaire::GetStartedForm::BUILDING,
              estimated_page_count: '10',
              # estimated_first_year_submissions_count is missing
              submission_delivery_method: 'email'
            }
          end

          it 'returns false' do
            expect(validator).to_not be_valid
          end
        end

        context 'when required fields are blank strings' do
          let(:answers) do
            {
              new_form_reason: Questionnaire::GetStartedForm::BUILDING,
              estimated_page_count: '',
              estimated_first_year_submissions_count: '100',
              submission_delivery_method: 'email'
            }
          end

          it 'returns false' do
            expect(validator).to_not be_valid
          end
        end
      end
    end
  end
end
