require 'rails_helper'

RSpec.describe Questionnaire::ContinueForm, type: :model do
  subject(:form) { described_class.new(attributes) }

  describe 'attributes' do
    context 'when continue_with_moj_forms is true' do
      let(:attributes) { { continue_with_moj_forms: true } }

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when continue_with_moj_forms is false' do
      let(:attributes) { { continue_with_moj_forms: false } }

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when continue_with_moj_forms is nil' do
      let(:attributes) { {} }

      it 'is invalid' do
        expect(form).not_to be_valid
        expect(form.errors[:continue_with_moj_forms]).to be_present
      end
    end
  end

  describe '#continue_with_moj_forms_options' do
    let(:attributes) { {} }

    it 'returns two options' do
      expect(form.continue_with_moj_forms_options.size).to eq(2)
    end

    it 'returns options with correct values' do
      values = form.continue_with_moj_forms_options.map(&:value)
      expect(values).to contain_exactly(false, true)
    end

    it 'returns options with translated names' do
      form.continue_with_moj_forms_options.each do |option|
        expect(option.name).to eq(
          I18n.t(
            "activemodel.attributes.questionnaire/continue_form/continue_with_moj_forms.#{option.value}"
          )
        )
      end
    end

    it 'returns OpenStruct objects' do
      expect(form.continue_with_moj_forms_options.first).to be_a(OpenStruct)
    end
  end

  describe '#previous_step_completed?' do
    let(:attributes) { {} }

    context 'when questionnaire_answers is empty' do
      it 'returns false' do
        expect(form.previous_step_completed?({})).to be_falsey
      end
    end

    context 'when govuk_forms_ruled_out is "false"' do
      let(:answers) { { govuk_forms_ruled_out: 'false' } }
      it 'returns true' do
        expect(form.previous_step_completed?(answers)).to be_truthy
      end
    end

    context 'when govuk_forms_ruled_out is "true"' do
      let(:answers) { { govuk_forms_ruled_out: 'true' } }

      it 'returns false' do
        expect(form.previous_step_completed?(answers)).to be_falsey
      end
    end
  end
end
