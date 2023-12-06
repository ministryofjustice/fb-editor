module MojForms
  module Flow
    class FlowItemComponent < GovukComponent::Base
      with_collection_parameter :item
      delegate :service, to: :helpers
      delegate :payment_link_enabled?, to: :helpers
      attr_reader :item, :html_attributes

      def initialize(item:, classes: [], html_attributes: {})
        @item = item
        @html_attributes = html_attributes

        super(classes:, html_attributes:)
      end

      def call
        case type
        when 'spacer'
          render(MojForms::Flow::SpacerComponent.new(item:, html_attributes: { 'aria-hidden': true }))
        when 'pointer'
          render(MojForms::Flow::PointerComponent.new(item:))
        when 'warning'
          render(MojForms::Flow::WarningComponent.new(item:))
        when 'branch'
          render(MojForms::Flow::BranchComponent.new(item:))
        else
          render(MojForms::Flow::PageComponent.new(item:))
        end
      end

      def default_attributes
        {
          id: uuid,
          class: "flow-item #{type_classname}",
          data: {
            fb_id: uuid
          }
        }
      end

      def uuid
        item[:uuid]
      end

      def type
        item[:type].gsub('page.', '').gsub('flow.', '')
      end

      def type_classname
        "flow-#{type}"
      end

      def thumbnail
        item[:thumbnail]
      end

      def title
        return item[:title] unless type == 'confirmation'
        return item[:title] unless payment_link_enabled?
        return item[:title] unless item[:title] == I18n.t('presenter.confirmation.application_complete')

        I18n.t('presenter.confirmation.payment_enabled')
      end

      def type_is?(*types)
        if types.length == 1
          type == types.first
        else
          types.include?(type)
        end
      end

      def edit_path
        if type == 'branch'
          edit_branch_path(service.service_id, item[:uuid])
        else
          edit_page_path(service.service_id, item[:uuid])
        end
      end
    end
  end
end
