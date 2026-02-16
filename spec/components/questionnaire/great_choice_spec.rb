require 'rails_helper'

RSpec.describe Questionnaire::GreatChoice, type: :model do
  subject(:component) { described_class.new }

  describe '#valid?' do
    context 'when questionnaire_answers is nil' do
      it 'returns false' do
        expect(component.valid?(nil)).to be_falsey
      end
    end

    context 'when questionnaire_answers is empty' do
      it 'returns false' do
        expect(component.valid?({})).to be_falsey
      end
    end

    context 'when new_form_reason is EXPERIMENT' do
      let(:answers) { { new_form_reason: Questionnaire::GetStartedForm::EXPERIMENT } }

      it 'returns true' do
        expect(component.valid?(answers)).to be_truthy
      end
    end

    context 'when new_form_reason is BUILDING' do
      let(:answers) { { new_form_reason: Questionnaire::GetStartedForm::BUILDING } }

      it 'returns false' do
        expect(component.valid?(answers)).to be_falsey
      end
    end
  end
end
