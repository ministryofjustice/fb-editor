class BaseComponentValidation
  attr_accessor :service, :page_uuid, :component_uuid, :validator, :status, :value

  include ActiveModel::Model

  validates :validator, inclusion: {
    in: proc { |obj| obj.supported_validations },
    message: lambda do |object, _|
      I18n.t(
        'activemodel.errors.models.base_component_validation.validator',
        validator: object.validator,
        component: object.component_type
      )
    end
  }
  with_options presence: {
    if: proc { |obj| obj.enabled? },
    message: lambda do |object, _|
               I18n.t(
                 'activemodel.errors.models.base_component_validation.blank',
                 label: object.label
               )
             end
  } do
    validates :value, unless: proc { |obj| obj.component_type == 'date' }
  end

  STRING_LENGTH_VALIDATIONS = %w[max_string_length min_string_length].freeze
  ENABLED = 'enabled'.freeze

  # Text and textarea components use a modal that shared configuration for character
  # length and word count. the actual validations are max_length, min_length,
  # max_word and min_word.
  # However the editor needs to map these to max_string_length and min_string_length
  # therefore we can allow requests with those validator types.
  def supported_validations
    validations = component.supported_validations
    return validations + STRING_LENGTH_VALIDATIONS if component.type.in?(%w[text textarea])

    validations
  end

  def assign_validation(validation_params)
    "#{validator.camelize}Validation".constantize.new(validation_params)
  rescue NameError
    validate
    self
  end

  def to_partial_path
    'new'
  end

  def default_metadata_key
    self.class::DEFAULT_METADATA_KEY
  end

  def enabled?
    return if status.blank?

    status == ENABLED || previously_enabled?
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
    meta[default_metadata_key] = main_value
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

  def default_metadata(key)
    DefaultMetadata["validations.#{key}"]
  end
end
