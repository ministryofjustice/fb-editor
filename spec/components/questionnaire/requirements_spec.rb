require 'rails_helper'

RSpec.describe Questionnaire::Requirements, type: :model do
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

    context 'when all required fields are present' do
      let(:answers) do
        {
          estimated_page_count: '10',
          estimated_first_year_submissions_count: '100',
          submission_delivery_method: 'email'
        }
      end

      it 'returns true' do
        expect(component.valid?(answers)).to be_truthy
      end
    end

    context 'when any required field is missing' do
      let(:answers) do
        {
          estimated_page_count: '10',
          estimated_first_year_submissions_count: '',
          submission_delivery_method: 'email'
        }
      end

      it 'returns false' do
        expect(component.valid?(answers)).to be_falsey
      end
    end
  end
end
