require 'rails_helper'

RSpec.describe Questionnaire::GreatChoice, type: :model do
  subject(:component) { described_class.new }

  describe '#previous_step_completed?' do
    context 'when questionnaire_answers is empty' do
      it 'returns false' do
        expect(component.previous_step_completed?({})).to be_falsey
      end
    end

    context 'when new_form_reason is EXPERIMENT' do
      let(:answers) { { new_form_reason: Questionnaire::GetStartedForm::EXPERIMENT } }

      it 'returns true' do
        expect(component.previous_step_completed?(answers)).to be_truthy
      end
    end

    context 'when new_form_reason is BUILDING' do
      let(:answers) { { new_form_reason: Questionnaire::GetStartedForm::BUILDING } }

      it 'returns false' do
        expect(component.previous_step_completed?(answers)).to be_falsey
      end
    end
  end
end
