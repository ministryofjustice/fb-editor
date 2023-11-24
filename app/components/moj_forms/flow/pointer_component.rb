module MojForms
  module Flow
    class PointerComponent < MojForms::Flow::FlowItemComponent
      def call
        tag.article tag.span(title), **html_attributes
      end
    end
  end
end
