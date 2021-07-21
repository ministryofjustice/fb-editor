class Conditional
  include ActiveModel::Model
  attr_accessor :next

  def to_metadata
    {
      '_type' => 'if', # need to get this from params too
      'next' => self.next, # probably should change this attribute name
      'expressions' => expressions.map(&:to_metadata)
    }
  end

  def ==(other)
    @next == other.next && expressions == other.expressions
  end

  def expressions
    @expressions ||= []
  end

  def expressions_attributes=(hash)
    hash.each do |_index, expression_hash|
      expressions.push(Expression.new(expression_hash))
    end
  end
end
