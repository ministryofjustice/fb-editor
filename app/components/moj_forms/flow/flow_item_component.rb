module MojForms
  module Flow
    class FlowItemComponent < ViewComponent::Base
      with_collection_parameter :item
      delegate :service, to: :helpers
      delegate :payment_link_enabled?, to: :helpers
      attr_reader :item

      def initialize(item:)
        @item = item
      end

      def uuid
        item[:uuid]
      end

      def type
        item[:type]
      end

      def thumbnail
        item[:thumbnail]
      end

      def title
        return item[:title] unless type == 'page.confirmation'
        return item[:title] unless payment_link_enabled?
        return item[:title] unless item[:title] == I18n.t('presenter.confirmation.application_complete')

        I18n.t('presenter.confirmation.payment_enabled')
      end

      def edit_path
        if type == 'flow.branch'
          edit_branch_path(service.service_id, item[:uuid])
        else
          edit_page_path(service.service_id, item[:uuid])
        end
      end

      def call
        case type
        when 'spacer'
          render(MojForms::Flow::SpacerComponent.new(item:))
        when 'pointer'
          render(MojForms::Flow::PointerComponent.new(item:))
        when 'warning'
          render(MojForms::Flow::WarningComponent.new(item:))
        when 'flow.branch'
          render(MojForms::Flow::BranchComponent.new(item:))
        else
          render(MojForms::Flow::PageComponent.new(item:))
        end
      end
    end
  end
end
