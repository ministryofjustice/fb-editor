module MojForms
  module FlowItems
    class PageComponent < MojForms::FlowItemComponent
      delegate :flow_thumbnail_link, to: :helpers
      delegate :flow_text_link, to: :helpers
    end
  end
end
