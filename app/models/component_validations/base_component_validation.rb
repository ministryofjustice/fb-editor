class BaseComponentValidation
  attr_accessor :service, :page_uuid, :component_uuid, :validator, :status, :value

  include ActiveModel::Model
  include ActiveModel::Validations
  validates_with BaseComponentValidationValidator

  ENABLED = 'enabled'.freeze

  def to_partial_path
    'new'
  end

  def enabled?
    previously_enabled? || status.present? && status == ENABLED
  end

  def run_validation?
    enabled? && value.present?
  end

  def component_type
    @component_type ||= component.type
  end

  def main_value
    value || component_validation[validator]
  end

  def label; end

  def status_label; end

  def to_json(*_args); end

  private

  def previously_enabled?
    component_validation.key(validator)
  end

  def component_validation
    @component_validation ||= component.validation
  end

  def component
    @component ||= page.find_component_by_uuid(component_uuid)
  end

  def page
    @page ||= service.find_page_by_uuid(page_uuid)
  end

  def default_metadata(key)
    DefaultMetadata["validations.#{key}"]
  end
end
