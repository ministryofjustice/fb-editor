require_relative './content_conditional_expression'

class ContentConditional < SitePrism::Section
    sections :expressions, ContentConditionalExpression, '[data-controller="expression"]' 
    element :add_condition, :button, I18n.t('conditional_content.add_condition')
    element :delete_button, '.conditional__remover'

    def first_expression
      expression(0)
    end

    def second_expression
      expression(1)
    end

    def expression(index)
      expressions[index]
    end
end
