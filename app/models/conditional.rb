class Conditional
  include ActiveModel::Model
  attr_accessor :next, :service
  attr_writer :expressions

  validates :next, presence: true
  validate :expressions_validations

  IF = 'if'.freeze
  AND = 'and'.freeze

  def initialize(attributes)
    @service = attributes.delete(:service)
    super
  end

  def to_metadata
    {
      '_uuid' => generate_uuid,
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
    hash.each_value do |expression_hash|
      expressions.push(
        Expression.new(
          expression_hash.merge(
            page: service.page_with_component(expression_hash['component'])
          )
        )
      )
    end
  end

  def expressions_validations
    expressions.map(&:invalid?)
  end

  private

  def conditional_type
    # The UI currently only supports IF and AND. The runner can also cater for
    # an OR but for the moment we have not surfaced that functionality
    expressions.count == 1 ? IF : AND
  end

  def generate_uuid
    SecureRandom.uuid
  end
end
