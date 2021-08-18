class Expression
  include ActiveModel::Model
  attr_accessor :component, :operator, :field, :page

  validates :component, :operator, :page, :field, presence: true

  OPERATORS = [
    [I18n.t('operators.is'), 'is'],
    [I18n.t('operators.is_not'), 'is_not'],
    [I18n.t('operators.is_answered'), 'is_answered'],
    [I18n.t('operators.is_not_answered'), 'is_not_answered']
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
end
