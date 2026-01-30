# frozen_string_literal: true

module Export
  class QuestionnairesCsv < ApplicationService
    PER_PAGE = 100_000_000 # maximize this number to get all questionnaires.BY default its 20 per page

    def call
      CSV.generate do |csv|
        csv << headers.map(&:humanize)

        questionnaires.each do |questionnaire|
          csv << build_row(questionnaire)
        end
      end
    end

    private

    def questionnaires
      @questionnaires ||= MetadataApiClient::Questionnaire
        .all_questionnaires(page: 1, per_page: PER_PAGE)
        .fetch(:questionnaires)
    end

    def headers
      %w[
        new_form_reason
        govuk_forms_ruled_out
        required_moj_forms_features
        govuk_forms_ruled_out_reason
        continue_with_moj_forms
        estimated_page_count
        estimated_first_year_submissions_count
        submission_delivery_method
        service_id
        created_at
      ]
    end

    def build_row(questionnaire)
      [
        t('get_started_form/new_form_reason', questionnaire.new_form_reason),
        t('gov_forms/govuk_forms_ruled_out', questionnaire.govuk_forms_ruled_out),
        translate_features(questionnaire.required_moj_forms_features),
        questionnaire.govuk_forms_ruled_out_reason,
        t('continue_form/continue_with_moj_forms', questionnaire.continue_with_moj_forms),
        t('new_form_form/estimated_page_count', questionnaire.estimated_page_count),
        t('new_form_form/estimated_first_year_submissions_count', questionnaire.estimated_first_year_submissions_count),
        t('new_form_form/submission_delivery_method', questionnaire.submission_delivery_method),
        questionnaire.service_id,
        questionnaire.created_at
      ]
    end

    def t(scope, value)
      return if value.nil?

      I18n.t("activemodel.attributes.questionnaire/#{scope}.#{value}")
    end

    def translate_features(features)
      return if features.blank?

      features
        .map { |feature| t('form_features_form/required_moj_forms_features', feature) }
        .join(', ')
    end
  end
end
