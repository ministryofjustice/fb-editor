class Expression
  include ActiveModel::Model
  attr_accessor :component, :operator, :field, :page

  OPERATORS = [
    %w[is is],
    ['is not', 'is_not'],
    ['is answered', 'is_answered'],
    ['is not answered', 'is_not_answered']
  ].freeze

  def to_metadata
    {
      'operator' => operator,
      'page' => page.uuid,
      'component' => component,
      'field' => field
    }
  end

  def ==(other)
    component == other.component
  end

  def answers
    component_obj = page.find_component_by_uuid(component)
    items = component_obj.items
    items.map { |item| [item.label, item.uuid] }
  end

  def operators
    OPERATORS
  end
end
