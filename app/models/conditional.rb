class Conditional
  include ActiveModel::Model
  attr_accessor :next, :expressions

  validates :next, presence: true

  IF = 'if'.freeze
  AND = 'and'.freeze

  def to_metadata
    {
      '_type' => conditional_type,
      'next' => self.next,
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

  private

  def conditional_type
    expressions.count == 1 ? IF : AND
  end
end
