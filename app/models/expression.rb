class Expression
  include ActiveModel::Model
  attr_accessor :component, :operator, :field, :page

  validates :component, :operator, :page, :field, presence: true
  validate :unsupported_component

  OPERATORS = [
    [I18n.t('operators.is'), 'is', { 'data-hide-answers': 'false' }],
    [I18n.t('operators.is_not'), 'is_not', { 'data-hide-answers': 'false' }],
    [I18n.t('operators.is_answered'), 'is_answered', { 'data-hide-answers': 'true' }],
    [I18n.t('operators.is_not_answered'), 'is_not_answered', { 'data-hide-answers': 'true' }]
  ].freeze

  def to_metadata
    {
      'operator' => operator,
      'page' => page&.uuid,
      'component' => component,
      'field' => field
    }
  end

  def ==(other)
    component == other.component
  end

  def answers
    component_object.items.map { |item| [item.label, item.uuid] }
  end

  def operators
    OPERATORS
  end

  def component_type
    component_object.type
  end

  def name_attr(conditional_index:, expression_index:, attribute:)
    "branch[conditionals_attributes][#{conditional_index}]" \
    "[expressions_attributes][#{expression_index}][#{attribute}]"
  end

  def id_attr(conditional_index:, expression_index:, attribute:)
    "branch_conditionals_attributes_#{conditional_index}_" \
    "expressions_attributes_#{expression_index}_#{attribute}"
  end

  private

  def component_object
    @component_object ||= page.find_component_by_uuid(component)
  end

  def unsupported_component
    if page.present? && component.present? && !component_object.supports_branching?
      errors.add(:component, message: I18n.t(
        'activemodel.errors.messages.unsupported_component'
      ))
    end
  end
end
