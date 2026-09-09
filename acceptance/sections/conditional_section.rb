require_relative './expression_section'

class ConditionalSection < SitePrism::Section
    sections :expressions, ExpressionSection, '[data-controller="expression"]'
    element :title, '[data-conditional-target="title"]'
    element :add_condition, :button, I18n.t('conditional_content.add_condition')
    element :delete_button, '.conditional__remover'
    element :destination_select, '.conditional__destination'

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
