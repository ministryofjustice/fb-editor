class Conditional
  include ActiveModel::Model
  attr_accessor :next, :expressions

  def ==(other)
    @next == other.next && expressions == other.expressions
  end

  def expressions
    @expressions ||= []
  end

  def expressions_attributes=(hash)
    hash.each do |index, expression_hash|
      expressions.push(Expression.new(expression_hash))
    end
  end
end
