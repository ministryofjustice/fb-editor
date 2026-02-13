class Questionnaire::NewFormForm
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :estimated_page_count, array: true
  attribute :estimated_first_year_submissions_count, array: true
  attribute :submission_delivery_method, array: true

  ESTIMATED_PAGE_COUNT_OPTIONS = %w[
    under_20
    20_to_50
    50_to_100
    over_100
  ].freeze

  ESTIMATED_FIRST_YEAR_SUBMISSIONS_COUNT_OPTIONS = %w[
    under_10000
    10000_to_100000
    over_100000
  ].freeze

  SUBMISSION_DELIVERY_METHOD_OPTIONS = %w[
    email
    collate
    direct_to_service
  ].freeze

  validates :estimated_page_count,
            inclusion: { in: ESTIMATED_PAGE_COUNT_OPTIONS,
                         message: I18n.t('activemodel.errors.models.questionnaire/new_form_form.estimated_page_count.inclusion') }

  validates :estimated_first_year_submissions_count,
            inclusion: { in: ESTIMATED_FIRST_YEAR_SUBMISSIONS_COUNT_OPTIONS,
                         message: I18n.t('activemodel.errors.models.questionnaire/new_form_form.estimated_first_year_submissions_count.inclusion') }

  validates :submission_delivery_method,
            inclusion: { in: SUBMISSION_DELIVERY_METHOD_OPTIONS,
                         message: I18n.t('activemodel.errors.models.questionnaire/new_form_form.submission_delivery_method.inclusion') }

  def estimated_page_count_options
    ESTIMATED_PAGE_COUNT_OPTIONS.map { |s| OpenStruct.new(value: s, name: I18n.t("activemodel.attributes.questionnaire/new_form_form/estimated_page_count.#{s}")) }
  end

  def estimated_first_year_submissions_count_options
    ESTIMATED_FIRST_YEAR_SUBMISSIONS_COUNT_OPTIONS.map { |s| OpenStruct.new(value: s, name: I18n.t("activemodel.attributes.questionnaire/new_form_form/estimated_first_year_submissions_count.#{s}")) }
  end

  def submission_delivery_method_options
    SUBMISSION_DELIVERY_METHOD_OPTIONS.map { |s| OpenStruct.new(value: s, name: I18n.t("activemodel.attributes.questionnaire/new_form_form/submission_delivery_method.#{s}")) }
  end

  def is_valid?(questionnaire_answers)
    return false unless questionnaire_answers

    (questionnaire_answers[:continue_with_moj_forms] == 'true') ||
      %i[
        required_moj_forms_features
        govuk_forms_ruled_out_reason
      ].all? { |key| questionnaire_answers[key].present? }
  end
end
