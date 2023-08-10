class ConditionalContent
  include ActiveModel::Model
  include ApplicationHelper
  attr_accessor :previous_flow_uuid, :service, :component_uuid
  attr_reader :traversable

  validate :conditionals_validations
  validates :conditional_content_uuid, presence: true

  def initialize(attributes)
    @service = attributes.delete(:service)
    @component_uuid = attributes.delete(component_uuid)
    @previous_flow_uuid = attributes.delete(previous_flow_uuid)
    @traversable = Traversable.new(service:, flow_uuid:)
    super
  end

  def self.from_metadata(flow_object)
    attributes_hash = {
      'conditionals_attributes' => {}
    }

    flow_object.conditionals.each_with_index do |conditional, index|
      attributes_hash['conditionals_attributes'][index.to_s] = expressions_attributes(conditional)
    end

    attributes_hash
  end

  def self.expressions_attributes(conditional)
    expressions_hash = { 'expressions_attributes' => {} }

    conditional.expressions.each_with_index do |expression, expression_index|
      expressions_hash['expressions_attributes'][expression_index.to_s] = {
        'operator' => expression.operator,
        'page' => expression.page,
        'component' => expression.component,
        'field' => expression.field
      }
    end

    expressions_hash
  end

  def conditionals_validations
    conditionals.map(&:invalid?)
  end

  def conditionals
    @conditionals ||= []
  end

  def conditionals_attributes=(hash)
    hash.each do |_index, conditional_hash|
      conditionals.push(ComponentConditional.new(conditional_hash.merge(service:)))
    end
  end

  def previous_questions
    results = traversable.question_pages.map do |page|
      page.input_components.map do |component|
        [
          component.humanised_title,
          component.uuid,
          { 'data-supports-branching': component.supports_branching? }
        ]
      end
    end

    results.flatten(1)
  end

  def flow_uuid
    return component_uuid if previous_flow_uuid.blank?

    previous_flow_uuid
  end
end
