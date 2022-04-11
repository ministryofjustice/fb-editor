class Move
  include ActiveModel::Model
  include ApplicationHelper
  attr_accessor :service, :grid, :previous_flow_uuid, :to_move_uuid, :target_uuid,
                :conditional_uuid

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

  private

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
      conditional_uuid: conditional&.uuid
    }.compact
  end

  def page_target(flow_object)
    {
      title: flow_title(flow_object),
      target_uuid: flow_object.uuid
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
end
