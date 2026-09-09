require 'rails_helper'

RSpec.describe Questionnaire::AttributesExtractor do
  subject(:extractor) { described_class.new(questionnaire) }

  describe '#extract!' do
    context 'when questionnaire is nil' do
      let(:questionnaire) { nil }

      it 'returns an empty hash' do
        expect(extractor.extract!).to eq({})
      end
    end

    context 'when questionnaire is empty' do
      let(:questionnaire) { {} }

      it 'returns an empty hash' do
        expect(extractor.extract!).to eq({})
      end
    end

    context "when new_form_reason is 'experiment'" do
      let(:questionnaire) do
        {
          new_form_reason: 'experiment',
          govuk_forms_ruled_out: 'true',
          estimated_page_count: 10
        }
      end

      it 'keeps only :new_form_reason' do
        expect(extractor.extract!).to eq(
          new_form_reason: 'experiment'
        )
      end
    end

    context "when govuk_forms_ruled_out is 'true'" do
      let(:questionnaire) do
        {
          new_form_reason: 'building',
          govuk_forms_ruled_out: 'true',
          required_moj_forms_features: %w[a],
          govuk_forms_ruled_out_reason: 'reason',
          estimated_page_count: 5,
          estimated_first_year_submissions_count: 100,
          submission_delivery_method: 'email',
          extra_key: 'should be removed'
        }
      end

      it 'keeps only ruled_out allowed keys' do
        expect(extractor.extract!).to eq(
          new_form_reason: 'building',
          govuk_forms_ruled_out: 'true',
          required_moj_forms_features: %w[a],
          govuk_forms_ruled_out_reason: 'reason',
          estimated_page_count: 5,
          estimated_first_year_submissions_count: 100,
          submission_delivery_method: 'email'
        )
      end
    end

    context "when govuk_forms_ruled_out is 'false' and continue_with_moj_forms is 'true'" do
      let(:questionnaire) do
        {
          new_form_reason: 'building',
          govuk_forms_ruled_out: 'false',
          continue_with_moj_forms: 'true',
          estimated_page_count: 3,
          estimated_first_year_submissions_count: 50,
          submission_delivery_method: 'email',
          unwanted: 'nope'
        }
      end

      it 'keeps only continue_with_moj allowed keys' do
        expect(extractor.extract!).to eq(
          new_form_reason: 'building',
          govuk_forms_ruled_out: 'false',
          continue_with_moj_forms: 'true',
          estimated_page_count: 3,
          estimated_first_year_submissions_count: 50,
          submission_delivery_method: 'email'
        )
      end
    end

    context "when govuk_forms_ruled_out is 'false' and continue_with_moj_forms is 'false'" do
      let(:questionnaire) do
        {
          new_form_reason: 'building',
          govuk_forms_ruled_out: 'false',
          continue_with_moj_forms: 'false',
          estimated_page_count: 99
        }
      end

      it 'clears the questionnaire' do
        expect(extractor.extract!).to eq({})
      end
    end

    context 'mutation behavior' do
      let(:questionnaire) do
        {
          govuk_forms_ruled_out: 'true',
          new_form_reason: 'x',
          extra: 'remove'
        }
      end

      it 'mutates the original hash' do
        extractor.extract!
        expect(questionnaire).to eq(
          govuk_forms_ruled_out: 'true',
          new_form_reason: 'x'
        )
      end
    end
  end
end
