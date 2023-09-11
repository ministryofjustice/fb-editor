class ComponentConditional
  include ActiveModel::Model
  attr_accessor :service
  attr_writer :expressions

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
      'expressions' => expressions.map(&:to_metadata)
    }
  end

  def ==(other)
    expressions == other.expressions
  end

  def expressions
    @expressions ||= []
  end

  def expressions_validations
    #expressions.map(&:invalid?)
    errors.add(:expressions, :invalid_expression) if expressions.map(&:invalid?).any?(true)
  end

  # this is tested in the ConditionalComponent model
  def expressions_attributes=(hash)
    hash.each do |_index, expression_hash|
      expressions.push(
        ComponentExpression.new(
          expression_hash.merge(
            page: service.page_with_component(expression_hash['component'])
          )
        )
      )
    end
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
