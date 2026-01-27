require 'rails_helper'

RSpec.describe Questionnaire::FormFeaturesForm, type: :model do
  subject(:form) { described_class.new(attributes) }

  describe 'attributes' do
    let(:attributes) do
      {
        required_moj_forms_features: %w[multiple_questions],
        govuk_forms_ruled_out_reason: 'Needs advanced logic'
      }
    end

    it 'is valid with valid attributes' do
      expect(form).to be_valid
    end

    it 'casts required_moj_forms_features as an array' do
      expect(form.required_moj_forms_features).to be_an(Array)
    end
  end

  describe 'validations' do
    context 'required_moj_forms_features' do
      context 'when value is allowed' do
        let(:attributes) do
          {
            required_moj_forms_features: %w[multiple_questions],
            govuk_forms_ruled_out_reason: 'Reason'
          }
        end

        it 'is valid' do
          expect(form).to be_valid
        end
      end

      context 'when value is not allowed' do
        let(:attributes) do
          {
            required_moj_forms_features: %w[invalid_feature],
            govuk_forms_ruled_out_reason: 'Reason'
          }
        end

        it 'is invalid' do
          expect(form).not_to be_valid
          expect(form.errors[:required_moj_forms_features]).to be_present
        end
      end
    end

    context 'govuk_forms_ruled_out_reason' do
      let(:attributes) do
        {
          required_moj_forms_features: %w[multiple_questions]
        }
      end

      it 'is invalid when missing' do
        expect(form).not_to be_valid
        expect(form.errors[:govuk_forms_ruled_out_reason]).to be_present
      end
    end
  end

  describe '#required_moj_forms_features_options' do
    let(:attributes) { {} }

    it 'returns one option per allowed feature' do
      expect(form.required_moj_forms_features_options.size)
        .to eq(described_class::REQUIRED_MOJ_FORMS_FEATURE_OPTIONS.size)
    end

    it 'returns OpenStruct options with correct values' do
      values = form.required_moj_forms_features_options.map(&:value)

      expect(values)
        .to match_array(described_class::REQUIRED_MOJ_FORMS_FEATURE_OPTIONS)
    end

    it 'returns options with translated names' do
      form.required_moj_forms_features_options.each do |option|
        expect(option.name).to eq(
          I18n.t(
            "activemodel.attributes.questionnaire/form_features_form/required_moj_forms_features.#{option.value}"
          )
        )
      end
    end

    it 'returns OpenStruct objects' do
      expect(form.required_moj_forms_features_options.first)
        .to be_a(OpenStruct)
    end
  end
end
