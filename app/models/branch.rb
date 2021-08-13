class Branch
  include ActiveModel::Model
  include BranchTitleGenerator
  attr_accessor :previous_flow_uuid, :service, :default_next
  attr_writer :title
  attr_reader :traversable

  delegate :branches, to: :service

  validate :conditionals_validations
  validates :default_next, presence: true

  def initialize(attributes)
    @service = attributes.delete(:service)
    @traversable = Traversable.new(service: service, flow_uuid: previous_flow_uuid)
    super
  end

  def title
    return @title if @title

    super
  end

  def self.from_metadata(flow_object)
    attributes_hash = {
      'default_next' => flow_object['next']['default'],
      'conditionals_attributes' => {},
      'title' => flow_object['title']
    }

    flow_object.conditionals.each_with_index do |conditional, index|
      attributes_hash['conditionals_attributes'][index.to_s] = {
        'next' => conditional.next
      }.merge(expressions_attributes(conditional))
    end

    attributes_hash
  end

  def self.expressions_attributes(conditional)
    expressions_hash = { 'expressions_attributes' => {} }

    conditional.expressions.each_with_index do |expression, expression_index|
      expressions_hash['expressions_attributes'][expression_index.to_s] = {
        'page' => expression.page,
        'component' => expression.component,
        'field' => expression.field
      }
    end

    expressions_hash
  end

  def conditionals_validations
    errors.add(:conditionals, 'Conditionals are not valid') if conditionals.map(&:invalid?).any?
  end

  def conditionals
    @conditionals ||= []
  end

  def conditionals_attributes=(hash)
    hash.each do |_index, conditional_hash|
      conditionals.push(Conditional.new(conditional_hash.merge(service: service)))
    end
  end

  def pages
    service.pages.map { |page| [page.title, page.uuid] }
  end

  def previous_questions
    results = traversable.question_pages.map do |page|
      page.input_components.map do |component|
        [
          component.humanised_title,
          component.uuid,
          { 'data-supports-branching': component.supports_branching? }
        ]
      end
    end

    results.flatten(1)
  end

  def previous_flow_title
    previous_flow_object.title
  end

  private

  def previous_flow_object
    service.find_page_by_uuid(previous_flow_uuid) ||
      service.flow_object(previous_flow_uuid)
  end
end
