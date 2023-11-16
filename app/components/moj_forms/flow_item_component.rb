module MojForms
  class FlowItemComponent < ViewComponent::Base
    include ApplicationHelper
    delegate :payment_link_enabled?, to: :helpers
    attr_reader :item, :service

    def initialize(item:, service:)
      @item = item
      @service = service
    end

    def type
      item[:type]
    end

    def call
      case type
      when 'spacer'
        render(MojForms::FlowItems::SpacerComponent.new(item:, service:))
      when 'pointer'
        render(MojForms::FlowItems::PointerComponent.new(item:, service:))
      when 'warning'
        render(MojForms::FlowItems::WarningComponent.new(item:, service:))
      when 'flow.branch'
        render(MojForms::FlowItems::BranchComponent.new(item:, service:))
      else
        render(MojForms::FlowItems::PageComponent.new(item:, service:))
      end
    end
  end
end
