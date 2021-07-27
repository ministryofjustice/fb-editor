class Expression
  include ActiveModel::Model
  attr_accessor :component, :operator, :field, :page

  def to_metadata
    {
      'operator' => operator,
      'page' => page,
      'component' => component,
      'field' => field
    }
  end

  def ==(other)
    component == other.component
  end
end
