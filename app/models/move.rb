class Move
  include ActiveModel::Model
  include ApplicationHelper
  include MetadataVersion
  attr_accessor :service, :grid, :previous_flow_uuid, :previous_conditional_uuid,
                :to_move_uuid, :target_uuid, :target_conditional_uuid

  alias_method :change, :create_version

  PARTIALS = {
    potential_stacked_branches?: 'stacked_branches_not_supported',
    branch_destination_no_default_next?: 'branch_destination_no_default_next',
    default?: 'new'
  }.freeze

  def title
    flow_title(service.flow_object(to_move_uuid))
  end

  def targets
    ordered_by_row.each_with_object([]) do |flow_object, ary|
      next if flow_object.nil? || invalid_target?(flow_object)

      if flow_object.branch?
        flow_object.conditionals.each.with_index(1) do |conditional, index|
          ary << branch_target(flow_object, index, conditional)
        end
        ary << branch_target(flow_object, flow_object.conditionals.count + 1)
      else
        ary << page_target(flow_object)
      end
    end
  end

  def metadata
    update_previous_flow_object if previous_flow_uuid.present?

    service.flow_object(target_uuid).branch? ? update_branch : update_page
    service.metadata.to_h.deep_stringify_keys
  end

  def to_partial_path
    result = PARTIALS.find do |method_name, _|
      method(method_name).call.present?
    end
    result[1]
  end

  private

  def potential_stacked_branches?
    previous_flow_is_a_branch? && to_move_default_next_is_branch?
  end

  def previous_flow_is_a_branch?
    service.flow_object(previous_flow_uuid)&.branch?
  end

  def to_move_default_next_is_branch?
    return if to_move_default_next.blank?

    service.flow_object(to_move_default_next).branch?
  end

  def to_move_default_next
    @to_move_default_next ||= service.flow_object(to_move_uuid).default_next
  end

  def branch_destination_no_default_next?
    previous_flow_is_a_branch? && to_move_default_next.blank?
  end

  # If the other checks returns false it means the page can be moved so
  # render 'new'
  def default?
    true
  end

  def ordered_by_row
    max_rows.times.each_with_object([]) do |row, ary|
      ordered_by_column.each do |column|
        ary << column[row] if column[row].present?
      end
    end
  end

  def branch_target(flow_object, index, conditional = nil)
    {
      title: "#{flow_object.title} (Branch #{index})",
      target_uuid: flow_object.uuid,
      conditional_uuid: conditional&.uuid,
      selected: conditional_next?(conditional) || branch_default_next?(flow_object)
    }.compact
  end

  def conditional_next?(conditional)
    return if conditional.blank?

    conditional.next == to_move_uuid
  end

  def branch_default_next?(flow_object)
    flow_object.uuid == previous_flow_uuid && flow_object.default_next == to_move_uuid
  end

  def page_target(flow_object)
    {
      title: flow_title(flow_object),
      target_uuid: flow_object.uuid,
      selected: flow_object.uuid == previous_flow_uuid
    }
  end

  def invalid_target?(flow_object)
    to_move_uuid == flow_object.uuid ||
      invalid_page?(flow_object.uuid) ||
      flow_object.is_a?(MetadataPresenter::Spacer) ||
      flow_object.is_a?(MetadataPresenter::Warning)
  end

  def invalid_page?(uuid)
    checkanswers_page?(uuid) || confirmation_page?(uuid) || exit_page?(uuid)
  end

  def checkanswers_page?(uuid)
    uuid == service.checkanswers_page&.uuid
  end

  def confirmation_page?(uuid)
    uuid == service.confirmation_page&.uuid
  end

  def exit_page?(uuid)
    service.find_page_by_uuid(uuid)&.type == 'page.exit'
  end

  def ordered_by_column
    @ordered_by_column ||= grid.build
  end

  def max_rows
    ordered_by_column.map(&:size).max
  end

  def update_previous_flow_object
    if branch_conditional?
      service.flow[previous_flow_uuid]['next']['conditionals'].each do |conditional|
        if conditional['_uuid'] == previous_conditional_uuid
          conditional['next'] = to_move_default_next
        end
      end
    else
      update_default_next(previous_flow_uuid, to_move_default_next)
    end
  end

  def branch_conditional?
    service.flow_object(previous_flow_uuid).branch? && previous_conditional_uuid.present?
  end

  def update_page
    set_target_uuid_as_to_move_default_next
    update_default_next(target_uuid, to_move_uuid)
  end

  def update_branch
    if target_conditional_uuid.present?
      service.flow[target_uuid]['next']['conditionals'].each do |conditional|
        if conditional['_uuid'] == target_conditional_uuid
          update_default_next(to_move_uuid, conditional['next'])
          conditional['next'] = to_move_uuid
        end
      end
    else
      set_target_uuid_as_to_move_default_next
      update_default_next(target_uuid, to_move_uuid)
    end
  end

  def set_target_uuid_as_to_move_default_next
    update_default_next(to_move_uuid, service.flow_object(target_uuid).default_next)
  end

  def update_default_next(to_update_uuid, new_default_next)
    # Exit pages have no default next.
    # If the new_default_next is the same as the to_update_uuid then the resulting
    # move would mean the page would be pointing to itself.
    return if exit_page?(to_update_uuid) || to_update_uuid == new_default_next

    service.flow[to_update_uuid]['next']['default'] = new_default_next
  end
end
