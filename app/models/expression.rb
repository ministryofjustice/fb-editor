class Expression
  include ActiveModel::Model
  attr_accessor :component

  def ==(other)
    component == other.component
  end
end
