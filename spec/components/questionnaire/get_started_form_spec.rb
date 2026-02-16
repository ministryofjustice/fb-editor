require 'rails_helper'

RSpec.describe Questionnaire::GetStartedForm, type: :model do
  subject(:form) { described_class.new(attributes) }

  describe 'attributes' do
    context 'with a valid new_form_reason' do
      let(:attributes) { { new_form_reason: 'building' } }

      it 'is valid' do
        expect(form).to be_valid
      end
    end
  end

  describe 'validations' do
    context 'when new_form_reason is allowed' do
      let(:attributes) { { new_form_reason: 'experiment' } }

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when new_form_reason is not allowed' do
      let(:attributes) { { new_form_reason: 'invalid' } }

      it 'is invalid' do
        expect(form).not_to be_valid
        expect(form.errors[:new_form_reason]).to be_present
      end
    end

    context 'when new_form_reason is nil' do
      let(:attributes) { {} }

      it 'is invalid' do
        expect(form).not_to be_valid
        expect(form.errors[:new_form_reason]).to be_present
      end
    end
  end

  describe '#new_form_reason_options' do
    let(:attributes) { {} }

    it 'returns one option per allowed reason' do
      expect(form.new_form_reason_options.size)
        .to eq(described_class::NEW_FORM_REASON_OPTIONS.size)
    end

    it 'returns OpenStruct options with correct values' do
      values = form.new_form_reason_options.map(&:value)

      expect(values)
        .to match_array(described_class::NEW_FORM_REASON_OPTIONS)
    end

    it 'returns options with translated names' do
      form.new_form_reason_options.each do |option|
        expect(option.name).to eq(
          I18n.t(
            "activemodel.attributes.questionnaire/get_started_form/new_form_reason.#{option.value}"
          )
        )
      end
    end

    it 'returns OpenStruct objects' do
      expect(form.new_form_reason_options.first)
        .to be_a(OpenStruct)
    end
  end

  describe '#valid?' do
    let(:attributes) { {} }

    it 'returns true' do
      expect(form.valid?({})).to be_truthy
      expect(form.valid?(nil)).to be_truthy
    end
  end
end
