class Expression
  include ActiveModel::Model
  attr_accessor :component, :operator, :field, :page

  validates :component, :operator, :page, presence: true
  validate :unsupported_component, :blank_field

  OPERATORS = [
    [I18n.t('operators.is'), 'is', { 'data-hide-answers': 'false' }],
    [I18n.t('operators.is_not'), 'is_not', { 'data-hide-answers': 'false' }],
    [I18n.t('operators.contains'), 'contains', { 'data-hide-answers': 'false' }],
    [I18n.t('operators.does_not_contain'), 'does_not_contain', { 'data-hide-answers': 'false' }],
    [I18n.t('operators.is_answered'), 'is_answered', { 'data-hide-answers': 'true' }],
    [I18n.t('operators.is_not_answered'), 'is_not_answered', { 'data-hide-answers': 'true' }]
  ].freeze

  def to_metadata
    {
      'operator' => operator,
      'page' => page&.uuid,
      'component' => component,
      'field' => field_answer
    }
  end

  def ==(other)
    component == other.component
  end

  def answers
    component_object.items.map { |item| [item.label, item.uuid] }
  end

  def all_operators
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

  def operators
    return contains_operators if is_checkbox?

    is_operators
  end

  private

  def component_object
    @component_object ||= page&.find_component_by_uuid(component)
  end

  def unsupported_component
    if page.present? && component.present? && !component_object.supports_branching?
      errors.add(:component, message: I18n.t(
        'activemodel.errors.messages.unsupported_component'
      ))
    end
  end

  def field_answer
    return field.to_s unless field_required?

    field
  end

  def field_required?
    operator == I18n.t('operators.is') || operator == I18n.t('operators.is_not')
  end

  def blank_field
    if field_required? && field.nil?
      errors.add(:operator, message: I18n.t(
        'activemodel.errors.messages.blank'
      ))
    end
  end

  def contains_operators
    @contains_operators ||= all_operators.select do |operator|
      operator.exclude?(I18n.t('operators.is')) && operator.exclude?(I18n.t('operators.is_not'))
    end
  end

  def is_operators
    @is_operators ||= all_operators.select do |operator|
      operator.exclude?(I18n.t('operators.contains')) && operator.exclude?(I18n.t('operators.does_not_contain'))
    end
  end

  def is_checkbox?
    component_type == 'checkboxes'
  end
end
