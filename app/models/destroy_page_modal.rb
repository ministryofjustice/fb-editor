class DestroyPageModal
  include ActiveModel::Model
  attr_accessor :service, :page

  PARTIALS = {
    potential_stack_branch?: 'stack_branches_not_supported',
    delete_page_used_for_branching?: 'delete_page_used_for_branching_not_supported',
    branch_destination?: 'delete_branch_destination_page',
    default?: 'delete'
  }.freeze

  def to_partial_path
    result = PARTIALS.find do |method_name, _|
      method(method_name).call.present?
    end

    "api/pages/#{result[1]}_modal"
  end

  def delete_page_used_for_branching?
    page.uuid.in?(expressions.map(&:page))
  end

  def potential_stack_branch?
    next_flow_is_a_branch? && previous_flow_is_a_branch?
  end

  def branch_destination?
    page.uuid.in?(branch_destinations)
  end

  # If the other checks returns false it means the page can be deleted
  # so let's render the default delete page
  #
  def default?
    true
  end

  private

  def next_flow_is_a_branch?
    default_next = service.flow_object(page.uuid).default_next

    default_next && service.flow_object(default_next).branch?
  end

  def previous_flow_is_a_branch?
    previous_flow_objects.any?(&:branch?)
  end

  def previous_flow_objects
    service.flow_objects.select do |flow|
      flow.default_next == page.uuid ||
        flow.conditionals.map(&:next).include?(page.uuid)
    end
  end

  def branch_destinations
    conditionals.map(&:next)
  end

  def expressions
    conditionals.map(&:expressions).flatten
  end

  def conditionals
    @conditionals ||= service.branches.map(&:conditionals).flatten
  end
end
