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

      def title
        title = 'If '
        expressions.each_with_index do |expression, idx|
          if expression[:operator].blank? && expression[:answer].blank?
            title << expression[:question]
          else
            title << "#{expression[:question]} #{expression[:operator]} #{expression[:answer]}"
          end
          if idx + 1 < expressions.size
            title << ' and '
          end
        end
        title
      end

      def branch_uuid
        branch[:uuid]
      end
    end
  end
end
