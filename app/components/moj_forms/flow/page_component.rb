module MojForms
  module Flow
    class PageComponent < MojForms::Flow::FlowItemComponent
      def default_attributes
        super.deep_merge({
          data: {
            next: next_uuid
          }.compact
        })
      end

      def type_classname
        'flow-page'
      end

      def next_uuid
        if item[:next].present?
          item[:next]
        elsif !type_is?('confirmation', 'exit')
          'trailing-route'
        end
      end

      def show_connection_menu?
        !(type_is?('confirmation', 'exit') || type_is?('checkanswers') && service.confirmation_page.present?)
      end
    end
  end
end
