require 'rails_helper'

RSpec.describe Questionnaire::Exit, type: :model do
  subject(:component) { described_class.new }

  describe '#is_valid?' do
    context 'when questionnaire_answers is nil' do
      it 'returns false' do
        expect(component.is_valid?(nil)).to be_falsey
      end
    end

    context 'when questionnaire_answers is empty' do
      it 'returns false' do
        expect(component.is_valid?({})).to be_falsey
      end
    end

    context 'when continue_with_moj_forms is "false"' do
      let(:answers) { { continue_with_moj_forms: 'false' } }

      it 'returns true' do
        expect(component.is_valid?(answers)).to be_truthy
      end
    end

    context 'when continue_with_moj_forms is "true"' do
      let(:answers) { { continue_with_moj_forms: 'true' } }

      it 'returns false' do
        expect(component.is_valid?(answers)).to be_falsey
      end
    end
  end
end
