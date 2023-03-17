module ComponentValidations
  class DateValidation < BaseComponentValidation
    attr_accessor :day, :month, :year

    with_options if: proc { |obj| obj.enabled? } do
      validates :day, :month, :year, presence: {
        message: lambda do |obj, data|
          I18n.t(
            'activemodel.errors.models.date_validation.missing_attribute',
            label: obj.label,
            attribute: data[:attribute].downcase
          )
        end
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
end
