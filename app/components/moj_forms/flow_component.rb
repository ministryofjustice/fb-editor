module MojForms
  class FlowComponent < ViewComponent::Base
    delegate :service, to: :helpers

    def initialize(flow:)
      super
      @flow = flow
    end
  end
end
