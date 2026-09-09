class ConditionalContent
  include ActiveModel::Model
  include ApplicationHelper
  attr_accessor :previous_flow_uuid, :service, :component_uuid, :display
  attr_reader :traversable

  validate :conditionals_validations
  validates :component_uuid, presence: true

  DISPLAY_OPTIONS = %w[always conditional never].map { |key|
    OpenStruct.new(value: key, text: I18n.t("conditional_content.display.#{key}"))
  }.freeze

  def initialize(attributes)
    @service = attributes.delete(:service)
    @component_uuid = attributes.delete(component_uuid)
    @previous_flow_uuid = attributes.delete(previous_flow_uuid)
    @traversable = Traversable.new(service:, flow_uuid:)
    super
  end

  def self.from_json(json)
    metadata = JSON.parse(json, object_class: OpenStruct)

    from_metadata(metadata)
  end

  def self.from_metadata(component)
    attributes_hash = {
      'conditionals_attributes' => {},
      'display' => component[:display] || 'always'
    }

    component.conditionals&.each_with_index do |conditional, index|
      attributes_hash['conditionals_attributes'][index.to_s] = expressions_attributes(conditional)
    end

    attributes_hash
  end

  def self.expressions_attributes(conditional)
    expressions_hash = { 'expressions_attributes' => {} }

    conditional.expressions.each_with_index do |expression, expression_index|
      expressions_hash['expressions_attributes'][expression_index.to_s] = {
        'operator' => expression.operator,
        'component' => expression.component,
        'field' => expression.field
      }
    end

    expressions_hash
  end

  def options_for_display
    DISPLAY_OPTIONS
  end

  def conditionals_validations
    conditionals.map(&:invalid?)
  end

  def conditionals
    @conditionals ||= []
  end

  def conditionals_attributes=(hash)
    hash.each_value do |conditional_hash|
      conditionals.push(ComponentConditional.new(conditional_hash.merge(service:, content_component: component_uuid)))
    end
  end

  def previous_questions
    results = traversable.question_pages.map do |page|
      page.input_components.map do |component|
        [
          component.humanised_title,
          component.uuid,
          {
            'data-supports-branching': component.supports_branching?,
            'data-same-page': page.uuid == content_component_page_uuid
          }
        ]
      end
    end

    results.flatten(1)
  end

  def flow_uuid
    return service.page_with_component(component_uuid)&.[](:_uuid) if previous_flow_uuid.blank?

    previous_flow_uuid
  end

  def content_component_page_uuid
    service.page_with_component(component_uuid)&.[](:_uuid)
  end

  def any_errors?
    conditional_errors? ||
      expression_errors? ||
      errors.present?
  end

  def conditional_errors?
    conditionals.any? do |conditional|
      conditional.errors.messages.present?
    end
  end

  def expression_errors?
    # failing here as operators are blank...
    expression_collection = conditionals.map(&:expressions)
    expression_collection.flatten.any? do |expression|
      expression.errors.messages.present?
    end
  end

  def to_metadata
    { display:, conditionals: conditionals.map(&:to_metadata) }
  end
end
