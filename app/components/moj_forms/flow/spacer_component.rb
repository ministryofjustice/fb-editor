module MojForms
  module Flow
    class SpacerComponent < MojForms::Flow::FlowItemComponent
      def call
        tag.article '', **html_attributes
      end
    end
  end
end
