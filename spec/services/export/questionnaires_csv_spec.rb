# frozen_string_literal: true

require 'rails_helper'
require 'ostruct'
require 'csv'

RSpec.describe Export::QuestionnairesCsv, type: :service do
  subject(:service) { described_class }

  let(:questionnaire) do
    OpenStruct.new(
      new_form_reason: 'building',
      govuk_forms_ruled_out: true,
      required_moj_forms_features: %w[multiple_questions save_progress],
      govuk_forms_ruled_out_reason: 'Legacy constraints',
      continue_with_moj_forms: false,
      estimated_page_count: '20_to_50',
      estimated_first_year_submissions_count: '10000_to_100000',
      submission_delivery_method: 'collate',
      service_id: 'service-123',
      created_at: Time.zone.parse('2024-01-01 10:00')
    )
  end

  let(:api_response) do
    {
      total_questionnaires: 1,
      questionnaires: [questionnaire]
    }
  end

  before do
    allow(MetadataApiClient::Questionnaire)
      .to receive(:all_questionnaires)
            .with(page: 1, per_page: Export::QuestionnairesCsv::PER_PAGE)
            .and_return(api_response)

    allow(I18n).to receive(:t) do |key|
      "translated: #{key}"
    end
  end

  describe '#call' do
    it 'returns a CSV string' do
      result = service.call

      expect(result).to be_a(String)
    end

    it 'includes the CSV headers' do
      csv = CSV.parse(service.call)

      expect(csv.first).to eq(
        [
          'New form reason',
          'Govuk forms ruled out',
          'Required moj forms features',
          'Govuk forms ruled out reason',
          'Continue with moj forms',
          'Estimated page count',
          'Estimated first year submissions count',
          'Submission delivery method',
          'Service',
          'Created at'
        ]
      )
    end

    it 'includes a row for each questionnaire' do
      csv = CSV.parse(service.call)

      expect(csv.size).to eq(2) # header + 1 row
    end

    it 'outputs translated values and raw fields correctly' do
      csv = CSV.parse(service.call)
      row = csv.second

      expect(row).to eq(
        [
          'translated: activemodel.attributes.questionnaire/get_started_form/new_form_reason.building',
          'translated: activemodel.attributes.questionnaire/gov_forms/govuk_forms_ruled_out.true',
          'translated: activemodel.attributes.questionnaire/form_features_form/required_moj_forms_features.multiple_questions, ' \
            'translated: activemodel.attributes.questionnaire/form_features_form/required_moj_forms_features.save_progress',
          'Legacy constraints',
          'translated: activemodel.attributes.questionnaire/continue_form/continue_with_moj_forms.false',
          'translated: activemodel.attributes.questionnaire/new_form_form/estimated_page_count.20_to_50',
          'translated: activemodel.attributes.questionnaire/new_form_form/estimated_first_year_submissions_count.10000_to_100000',
          'translated: activemodel.attributes.questionnaire/new_form_form/submission_delivery_method.collate',
          'service-123',
          '2024-01-01 10:00:00 UTC'
        ]
      )
    end

    context 'when optional values are nil' do
      let(:questionnaire) do
        OpenStruct.new(
          new_form_reason: nil,
          govuk_forms_ruled_out: nil,
          required_moj_forms_features: nil,
          govuk_forms_ruled_out_reason: nil,
          continue_with_moj_forms: nil,
          estimated_page_count: nil,
          estimated_first_year_submissions_count: nil,
          submission_delivery_method: nil,
          service_id: 'service-456',
          created_at: Time.zone.parse('2024-02-01 09:00')
        )
      end

      it 'outputs blank values instead of translations' do
        csv = CSV.parse(service.call)
        row = csv.second

        expect(row).to include(
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          'service-456',
          '2024-02-01 09:00:00 UTC'
        )
      end
    end
  end
end
