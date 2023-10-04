require_relative './content_conditional_expression'

class ContentConditional < SitePrism::Section
    sections :expressions, ContentConditionalExpression, '.expression' 
    element :add_condition, :button, I18n.t('conditional_content.add_condition')
    element :delete_button, '.conditional__remover'
end
