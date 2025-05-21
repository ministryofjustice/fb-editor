module MojForms
  module Flow
    class BranchConditionalsComponent < ViewComponent::Base
      attr_reader :branch

      def initialize(branch:)
        super
        @branch = branch
      end

      def conditionals
        branch[:conditionals]
      end

      def call
        tag.ul class: 'flow-conditions' do
          render MojForms::Flow::BranchConditionalComponent.with_collection(conditionals, branch:)
        end
      end
    end
  end
end
