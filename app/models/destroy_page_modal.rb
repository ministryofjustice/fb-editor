class DestroyPageModal
  include ActiveModel::Model
  include ConfirmationEmailModalHelper

  attr_accessor :service, :page

  delegate :expressions, :branches, to: :service

  PARTIALS = {
    potential_stacked_branches?: 'stack_branches_not_supported',
    delete_page_used_for_branching?: 'delete_page_used_for_branching_not_supported',
    branch_destination_with_default_next?: 'delete_branch_destination_page',
    branch_destination_no_default_next?: 'delete_branch_destination_page_no_default_next',
    delete_page_used_for_confirmation_email?: 'delete_page_used_for_confirmation_email',
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

  def potential_stacked_branches?
    next_flow_is_a_branch? && previous_flow_is_a_branch?
  end

  def branch_destination_with_default_next?
    branch_destination? && page_flow_object.default_next.present?
  end

  def branch_destination_no_default_next?
    branch_destination? && page_flow_object.default_next.blank?
  end

  def delete_page_used_for_confirmation_email?
    return unless confirmation_email_setting_checked?

    email_component_used_for_confirmation_email?
  end

  # If the other checks returns false it means the page can be deleted
  # so let's render the default delete page
  #
  def default?
    true
  end

  private

  def branch_destination?
    @branch_destination ||= page.uuid.in?(branch_destinations)
  end

  def page_flow_object
    @page_flow_object ||= service.flow_object(page.uuid)
  end

  def next_flow_is_a_branch?
    default_next = page_flow_object.default_next

    default_next && service.flow_object(default_next).branch?
  end

  def previous_flow_is_a_branch?
    previous_flow_objects.any?(&:branch?)
  end

  def previous_flow_objects
    service.flow_objects.select do |flow|
      flow.all_destination_uuids.include?(page.uuid)
    end
  end

  def branch_destinations
    branches.map(&:all_destination_uuids).flatten
  end

  def email_component_used_for_confirmation_email?
    (email_component_id_on_page & confirmation_email_component_ids).any?
  end

  def email_components_on_page
    @email_components_on_page ||=
      page.components.select do |component|
        component.type == 'email'
      end
  end

  def email_component_id_on_page
    @email_component_id_on_page ||= email_components_on_page.map(&:id)
  end
end
