module MojForms
  module Flow
    class BranchConditionalComponent < ViewComponent::Base
      with_collection_parameter(:conditional)
      attr_reader :branch, :conditional, :index

      def initialize(conditional:, conditional_iteration:, branch:)
        super
        @branch = branch
        @conditional = conditional
        @index = conditional_iteration.index
      end

      def expressions
        conditional[:expressions]
      end

      def branch_uuid
        branch[:uuid]
      end
    end
  end
end
