class BaseComponentValidation
  attr_accessor :service, :page_uuid, :component_uuid, :validator, :status, :value

  include ActiveModel::Model
  include ActiveModel::Validations

  validates :validator, inclusion: {
    in: proc { |obj| obj.component.supported_validations },
    message: lambda do |object, _|
      I18n.t(
        'activemodel.errors.models.base_component_validation.validator',
        validator: object.validator,
        component: object.component_type
      )
    end
  }
  validates :value, presence: {
    if: proc { |obj| obj.enabled? },
    message: lambda do |object, _|
      I18n.t(
        'activemodel.errors.models.base_component_validation.blank',
        label: object.label
      )
    end
  }

  ENABLED = 'enabled'.freeze

  def assign_validation
    return self unless valid?

    "#{validator.camelize}Validation".constantize.new(
      service: service,
      page_uuid: page_uuid,
      component_uuid: component_uuid,
      validator: validator,
      status: status,
      value: value
    )
  end

  def to_partial_path
    'new'
  end

  def enabled?
    previously_enabled? || status.present? && status == ENABLED
  end

  def run_validation?
    enabled? && value.present?
  end

  def component
    @component ||= page.find_component_by_uuid(component_uuid)
  end

  def component_type
    @component_type ||= component.type
  end

  def main_value
    value || component_validation[validator]
  end

  def to_metadata
    return { default_metadata_key => '' } if status.blank?

    meta = default_metadata(default_metadata_key)
    meta[default_metadata_key] = value
    meta
  end

  def label; end

  def status_label; end

  private

  def previously_enabled?
    component_validation.key?(validator)
  end

  def component_validation
    @component_validation ||= component.validation
  end

  def page
    @page ||= service.find_page_by_uuid(page_uuid)
  end

  def default_metadata_key
    self.class::DEFAULT_METADATA_KEY
  end

  def default_metadata(key)
    DefaultMetadata["validations.#{key}"]
  end
end
