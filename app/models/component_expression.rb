class ComponentExpression
  include ActiveModel::Model
  attr_accessor :component, :operator, :field, :service, :page, :content_component_page

  validates :component, presence: true
  validates :component, supported_component: true
  validates :component, non_same_page: true
  # validates :operator, presence: true, if: proc { |e| e.component && e.component_supported? && !e.component_on_same_page? }
  validates_each :field do |record, attribute, _value|
    if record.field_required? && record.field.nil?
      record.errors.add(
        attribute,
        I18n.t('activemodel.errors.messages.blank', attribute: ComponentExpression.human_attribute_name(attribute))
      )
    end
  end

  OPERATORS = [
    [I18n.t('operators.is'), 'is', { 'data-hide-answers': 'false' }],
    [I18n.t('operators.is_not'), 'is_not', { 'data-hide-answers': 'false' }],
    [I18n.t('operators.contains'), 'contains', { 'data-hide-answers': 'false' }],
    [I18n.t('operators.does_not_contain'), 'does_not_contain', { 'data-hide-answers': 'false' }],
    [I18n.t('operators.is_answered'), 'is_answered', { 'data-hide-answers': 'true' }],
    [I18n.t('operators.is_not_answered'), 'is_not_answered', { 'data-hide-answers': 'true' }]
  ].freeze

  def initialize(attributes)
    @service = attributes.delete(:service)
    @page = attributes.delete(:page)
    @content_component_page = attributes.delete(:content_component_page)
    super
  end

  def to_metadata
    {
      'operator' => operator,
      'page' => page.uuid,
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

  def operators
    return contains_operators if is_checkbox?

    is_operators
  end

  def answered_operator_values
    answered_operators.map { |operator| operator[1] }
  end

  def component_type
    component_object.type
  end

  def component_supported?
    component_object&.supports_branching?
  end

  def component_on_different_page?
    page.uuid != content_component_page.uuid
  end

  def name_attr(conditional_index:, expression_index:, attribute:)
    "conditional_content[conditionals_attributes][#{conditional_index}]" \
    "[expressions_attributes][#{expression_index}][#{attribute}]"
  end

  def id_attr(conditional_index:, expression_index:, attribute:)
    "conditional_content_conditionals_attributes_#{conditional_index}_" \
    "expressions_attributes_#{expression_index}_#{attribute}"
  end

  def field_required?
    operator == I18n.t('operators.is') || operator == I18n.t('operators.is_not')
  end

  # private

  def field_answer
    return field.to_s unless field_required?

    field
  end

  def component_object
    @component_object ||= page.find_component_by_uuid(component)
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

  def answered_operators
    @answered_operators ||= all_operators.select do |operator|
      operator.include?(I18n.t('operators.is_answered')) || operator.include?(I18n.t('operators.is_not_answered'))
    end
  end

  def is_checkbox?
    component_type == 'checkboxes'
  end
end
