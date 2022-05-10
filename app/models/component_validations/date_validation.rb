class DateValidation < BaseComponentValidation
  attr_accessor :day, :month, :year

  with_options if: proc { |obj| obj.enabled? } do
    validates :day, presence: {
      message: I18n.t(
        'activemodel.errors.models.base_component_validation.blank',
        label: I18n.t('dialogs.component_validations.date.day')
      )
    }
    validates :month, presence: {
      message: I18n.t(
        'activemodel.errors.models.base_component_validation.blank',
        label: I18n.t('dialogs.component_validations.date.month')
      )
    }
    validates :year, presence: {
      message: I18n.t(
        'activemodel.errors.models.base_component_validation.blank',
        label: I18n.t('dialogs.component_validations.date.year')
      )
    }
  end
  validates_with DateValidator, if: :run_validation?

  def run_validation?
    enabled? && (day.present? && month.present? && year.present?)
  end

  def answered_day
    day || parsed_date_answer&.day
  end

  def answered_month
    month || parsed_date_answer&.month
  end

  def answered_year
    year || parsed_date_answer&.year
  end

  def main_value
    formatted_date || component_validation[validator]
  end

  private

  def formatted_date
    Date.strptime("#{year}-#{month}-#{day}", '%Y-%m-%d').iso8601
  end

  def parsed_date_answer
    @parsed_date_answer ||= begin
      return if component_validation[validator].blank?

      Date.parse(component_validation[validator], '%Y-%m-%d')
    end
  end
end
