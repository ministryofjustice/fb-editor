require_relative './content_conditional'

class ConditionalContentModal < SitePrism::Section
    element :display_always_radio, '#conditional-content-display-always-field', visible: :all 
    element :display_never_radio, '#conditional-content-display-never-field', visible: :all
    element :display_conditional_radio, '#conditional-content-display-conditional-field', visible: :all
    element :conditionals_container, '.conditionals'
    sections :conditionals, ContentConditional, '.conditional[data-conditional-index]'
    element :add_another_rule, :button, I18n.t('conditional_content.add_another_rule')
end
