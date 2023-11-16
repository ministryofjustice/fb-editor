module MojForms
  class FlowComponent < ViewComponent::Base
    delegate :service, to: :helpers

    def initialize(flow:)
      @flow = flow
    end
  end
end
