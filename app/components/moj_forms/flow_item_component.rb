module MojForms
  class FlowItemComponent < ViewComponent::Base
    with_collection_parameter :item
    delegate :service, to: :helpers
    attr_reader :item

    def initialize(item:)
      @item = item
    end

    def type
      item[:type]
    end

    def call
      case type
      when 'spacer'
        render(MojForms::FlowItems::SpacerComponent.new(item:))
      when 'pointer'
        render(MojForms::FlowItems::PointerComponent.new(item:))
      when 'warning'
        render(MojForms::FlowItems::WarningComponent.new(item:))
      when 'flow.branch'
        render(MojForms::FlowItems::BranchComponent.new(item:))
      else
        render(MojForms::FlowItems::PageComponent.new(item:))
      end
    end
  end
end
