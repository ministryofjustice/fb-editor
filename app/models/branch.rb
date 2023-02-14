class Branch
  include ActiveModel::Model
  include ApplicationHelper
  include DestinationsList
  include BranchTitleGenerator
  include PreviousPageTitle
  attr_accessor :previous_flow_uuid, :service, :default_next, :branch_uuid
  attr_writer :title
  attr_reader :traversable

  delegate :branches, to: :service

  validate :conditionals_validations
  validates :default_next, presence: true

  def initialize(attributes)
    @service = attributes.delete(:service)
    @traversable = Traversable.new(service:, flow_uuid: previous_flow_uuid)
    @branch_uuid = attributes.delete(:branch_uuid)
    @previous_flow_uuid = attributes.delete(:previous_flow_uuid)
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
        'operator' => expression.operator,
        'page' => expression.page,
        'component' => expression.component,
        'field' => expression.field
      }
    end

    expressions_hash
  end

  def conditionals_validations
    conditionals.map(&:invalid?)
  end

  def conditionals
    @conditionals ||= []
  end

  def conditionals_attributes=(hash)
    hash.each do |_index, conditional_hash|
      conditionals.push(Conditional.new(conditional_hash.merge(service:)))
    end
  end

  def destinations
    all_flow_objects = ordered_pages + detached.flow_objects
    destinations_list(flow_objects: all_flow_objects)
  end

  def main_destinations
    destinations_list(flow_objects: ordered_pages)
  end

  def detached_destinations
    destinations_list(flow_objects: detached.ordered_no_branches)
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

  def flow_uuid
    return branch_uuid if previous_flow_uuid.blank?

    previous_flow_uuid
  end

  def previous_flow_default_next
    service.flow_object(flow_uuid).default_next
  end

  def previous_pages
    service.pages
  end

  def any_errors?
    conditional_errors? ||
      expression_errors? ||
      errors.present?
  end

  def conditional_errors?
    conditionals.any? do |conditional|
      conditional.errors.messages.present?
    end
  end

  def expression_errors?
    expression_collection = conditionals.map(&:expressions)
    expression_collection.flatten.any? do |expression|
      expression.errors.messages.present?
    end
  end

  private

  def grid
    @grid ||= MetadataPresenter::Grid.new(service)
  end

  def ordered_pages
    @ordered_pages ||= grid.ordered_pages
  end

  def detached
    Detached.new(
      service:,
      main_flow_uuids: grid.page_uuids,
      exclude_branches: true
    )
  end

  def previous_flow_object
    service.find_page_by_uuid(previous_flow_uuid) ||
      service.flow_object(previous_flow_uuid)
  end
end
