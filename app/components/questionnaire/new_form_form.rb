class Questionnaire::NewFormForm
  include ActiveModel::API
  attr_accessor :estimated_page_count,
                :estimated_first_year_submissions_count,
                :submission_delivery_method

  ESTIMATED_PAGE_COUNT_OPTIONS = %w[under_20 20_to_50 50_to_100 over_100].freeze
  ESTIMATED_FIRST_YEAR_SUBMISSIONS_COUNT_OPTIONS = %w[under_10000 10000_to_100000 over_100000].freeze
  SUBMISSION_DELIVERY_METHOD_OPTIONS = %w[email collate direct_to_service].freeze

  validates :estimated_page_count,
            inclusion: { in: ESTIMATED_PAGE_COUNT_OPTIONS,
                         message: I18n.t('activemodel.errors.models.questionnaire/new_form_form.estimated_page_count.inclusion') },
            presence: { messgae: I18n.t('activemodel.errors.models.questionnaire/new_form_form.estimated_page_count.blank') }

  validates :estimated_first_year_submissions_count,
            inclusion: { in: ESTIMATED_FIRST_YEAR_SUBMISSIONS_COUNT_OPTIONS,
                         message: I18n.t('activemodel.errors.models.questionnaire/new_form_form.estimated_first_year_submissions_count.inclusion') },
            presence: { messgae: I18n.t('activemodel.errors.models.questionnaire/new_form_form.estimated_first_year_submissions_count.blank') }

  validates :submission_delivery_method,
            inclusion: { in: SUBMISSION_DELIVERY_METHOD_OPTIONS,
                         message: I18n.t('activemodel.errors.models.questionnaire/new_form_form.submission_delivery_method.inclusion') },
            presence: { messgae: I18n.t('activemodel.errors.models.questionnaire/new_form_form.submission_delivery_method.blank') }

  def estimated_page_count_options
    ESTIMATED_PAGE_COUNT_OPTIONS.map { |s| OpenStruct.new(value: s, name: s.humanize) }
  end

  def estimated_first_year_submissions_count_options
    ESTIMATED_FIRST_YEAR_SUBMISSIONS_COUNT_OPTIONS.map { |s| OpenStruct.new(value: s, name: s.humanize) }
  end

  def submission_delivery_method_options
    SUBMISSION_DELIVERY_METHOD_OPTIONS.map { |s| OpenStruct.new(value: s, name: s.humanize) }
  end
end
