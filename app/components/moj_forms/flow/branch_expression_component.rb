module MojForms
  module Flow
    class BranchExpressionComponent < ViewComponent::Base
      with_collection_parameter(:expression)
      attr_reader :expression, :iteration

      def initialize(expression:, expression_iteration:)
        super
        @expression = expression
        @iteration = expression_iteration
      end

      def question
        expression[:question]
      end

      def operator
        expression[:operator]
      end

      def answer
        expression[:answer]
      end

      def otherwise_expression?
        operator.empty? && answer.empty?
      end
    end
  end
end
