require 'rails_helper'

RSpec.describe Questionnaire::GovForms, type: :model do
  subject(:form) { described_class.new(attributes) }

  describe 'attributes' do
    context 'when govuk_forms_ruled_out is true' do
      let(:attributes) { { govuk_forms_ruled_out: true } }

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when govuk_forms_ruled_out is false' do
      let(:attributes) { { govuk_forms_ruled_out: false } }

      it 'is valid' do
        expect(form).to be_valid
      end
    end
  end

  describe 'validations' do
    context 'when govuk_forms_ruled_out is nil' do
      let(:attributes) { {} }

      it 'is invalid' do
        expect(form).not_to be_valid
        expect(form.errors[:govuk_forms_ruled_out]).to be_present
      end
    end
  end

  describe '#govuk_forms_ruled_out_options' do
    let(:attributes) { {} }

    it 'returns two options' do
      expect(form.govuk_forms_ruled_out_options.size).to eq(2)
    end

    it 'returns options with correct values' do
      values = form.govuk_forms_ruled_out_options.map(&:value)

      expect(values).to contain_exactly(true, false)
    end

    it 'returns options with translated names' do
      form.govuk_forms_ruled_out_options.each do |option|
        expect(option.name).to eq(
          I18n.t(
            "activemodel.attributes.questionnaire/gov_forms/govuk_forms_ruled_out.#{option.value}"
          )
        )
      end
    end

    it 'returns OpenStruct objects' do
      expect(form.govuk_forms_ruled_out_options.first)
        .to be_a(OpenStruct)
    end
  end

  describe '#is_valid?' do
    let(:attributes) { {} }

    context 'when questionnaire_answers is nil' do
      it 'returns false' do
        expect(form.is_valid?(nil)).to be_falsey
      end
    end

    context 'when questionnaire_answers is empty' do
      it 'returns false' do
        expect(form.is_valid?({})).to be_falsey
      end
    end

    context 'when new_form_reason is BUILDING' do
      let(:answers) { { new_form_reason: Questionnaire::GetStartedForm::BUILDING } }

      it 'returns true' do
        expect(form.is_valid?(answers)).to be_truthy
      end
    end

    context 'when new_form_reason is EXPERIMENT' do
      let(:answers) { { new_form_reason: Questionnaire::GetStartedForm::EXPERIMENT } }

      it 'returns false' do
        expect(form.is_valid?(answers)).to be_falsey
      end
    end
  end
end
