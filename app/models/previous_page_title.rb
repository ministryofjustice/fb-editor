module PreviousPageTitle
  def previous_page_title
    @previous_page_title ||= begin
      return previous_flow_object.title if respond_to?(:previous_flow_uuid) && previous_flow_uuid.present?

      titles = service.flow_objects.map do |flow|
        flow_title(flow) if flow.all_destination_uuids.include?(branch_uuid)
      end

      titles.compact.first
    end
  end
end
