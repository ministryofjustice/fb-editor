class Conditional
  include ActiveModel::Model
  attr_accessor :next, :service
  attr_writer :expressions

  validates :next, presence: true

  IF = 'if'.freeze
  AND = 'and'.freeze

  def initialize(attributes)
    @service = attributes.delete(:service)
    super
  end

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
      expressions.push(
        Expression.new(
          expression_hash.merge(
            page: service.page_with_component(expression_hash['component'])
          )
        )
      )
    end
  end

  private

  def conditional_type
    expressions.count == 1 ? IF : AND
  end
end
