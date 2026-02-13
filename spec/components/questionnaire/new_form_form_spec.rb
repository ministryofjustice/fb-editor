require 'rails_helper'

RSpec.describe Questionnaire::NewFormForm, type: :model do
  subject(:form) { described_class.new(attributes) }

  let(:valid_attributes) do
    {
      estimated_page_count: %w[under_20],
      estimated_first_year_submissions_count: %w[under_10000],
      submission_delivery_method: %w[email]
    }
  end

  describe 'attributes' do
    let(:attributes) { valid_attributes }

    it 'is valid with valid attributes' do
      expect(form).to be_valid
    end

    it 'casts attributes as arrays' do
      expect(form.estimated_page_count).to be_an(Array)
      expect(form.estimated_first_year_submissions_count).to be_an(Array)
      expect(form.submission_delivery_method).to be_an(Array)
    end
  end

  describe 'validations' do
    context 'estimated_page_count' do
      context 'when missing' do
        let(:attributes) { valid_attributes.except(:estimated_page_count) }

        it 'is invalid' do
          expect(form).not_to be_valid
          expect(form.errors[:estimated_page_count]).to be_present
        end
      end

      context 'when not included in allowed options' do
        let(:attributes) { valid_attributes.merge(estimated_page_count: %w[invalid]) }

        it 'is invalid' do
          expect(form).not_to be_valid
          expect(form.errors[:estimated_page_count]).to be_present
        end
      end
    end

    context 'estimated_first_year_submissions_count' do
      context 'when missing' do
        let(:attributes) { valid_attributes.except(:estimated_first_year_submissions_count) }

        it 'is invalid' do
          expect(form).not_to be_valid
          expect(form.errors[:estimated_first_year_submissions_count]).to be_present
        end
      end

      context 'when not included in allowed options' do
        let(:attributes) do
          valid_attributes.merge(
            estimated_first_year_submissions_count: %w[invalid]
          )
        end

        it 'is invalid' do
          expect(form).not_to be_valid
          expect(form.errors[:estimated_first_year_submissions_count]).to be_present
        end
      end
    end

    context 'submission_delivery_method' do
      context 'when missing' do
        let(:attributes) { valid_attributes.except(:submission_delivery_method) }

        it 'is invalid' do
          expect(form).not_to be_valid
          expect(form.errors[:submission_delivery_method]).to be_present
        end
      end

      context 'when not included in allowed options' do
        let(:attributes) do
          valid_attributes.merge(submission_delivery_method: %w[invalid])
        end

        it 'is invalid' do
          expect(form).not_to be_valid
          expect(form.errors[:submission_delivery_method]).to be_present
        end
      end
    end
  end

  describe '#estimated_page_count_options' do
    let(:attributes) { {} }

    it 'returns one option per allowed value' do
      expect(form.estimated_page_count_options.size)
        .to eq(described_class::ESTIMATED_PAGE_COUNT_OPTIONS.size)
    end

    it 'returns OpenStruct options with correct values' do
      values = form.estimated_page_count_options.map(&:value)

      expect(values)
        .to match_array(described_class::ESTIMATED_PAGE_COUNT_OPTIONS)
    end
  end

  describe '#estimated_first_year_submissions_count_options' do
    let(:attributes) { {} }

    it 'returns one option per allowed value' do
      expect(form.estimated_first_year_submissions_count_options.size)
        .to eq(described_class::ESTIMATED_FIRST_YEAR_SUBMISSIONS_COUNT_OPTIONS.size)
    end

    it 'returns OpenStruct options with correct values' do
      values = form.estimated_first_year_submissions_count_options.map(&:value)

      expect(values)
        .to match_array(described_class::ESTIMATED_FIRST_YEAR_SUBMISSIONS_COUNT_OPTIONS)
    end
  end

  describe '#submission_delivery_method_options' do
    let(:attributes) { {} }

    it 'returns one option per allowed value' do
      expect(form.submission_delivery_method_options.size)
        .to eq(described_class::SUBMISSION_DELIVERY_METHOD_OPTIONS.size)
    end

    it 'returns OpenStruct options with correct values' do
      values = form.submission_delivery_method_options.map(&:value)

      expect(values)
        .to match_array(described_class::SUBMISSION_DELIVERY_METHOD_OPTIONS)
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

    context 'when continue_with_moj_forms is "true"' do
      let(:answers) { { continue_with_moj_forms: 'true' } }

      it 'returns true' do
        expect(form.is_valid?(answers)).to be_truthy
      end
    end

    context 'when continue_with_moj_forms is "false"' do
      context 'when other required fields are present' do
        let(:answers) do
          {
            continue_with_moj_forms: 'false',
            required_moj_forms_features: 'some features',
            govuk_forms_ruled_out_reason: 'some reason'
          }
        end

        it 'returns true' do
          expect(form.is_valid?(answers)).to be_truthy
        end
      end

      context 'when other required fields are missing' do
        let(:answers) do
          {
            continue_with_moj_forms: 'false',
            required_moj_forms_features: '',
            govuk_forms_ruled_out_reason: ''
          }
        end

        it 'returns false' do
          expect(form.is_valid?(answers)).to be_falsey
        end
      end
    end
  end
end
