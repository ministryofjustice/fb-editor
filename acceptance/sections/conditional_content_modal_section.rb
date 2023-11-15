require_relative './conditional_section'

class ConditionalContentModalSection < SitePrism::Section
    element :display_always_radio, '#conditional-content-display-always-field', visible: :all
    element :display_never_radio, '#conditional-content-display-never-field', visible: :all
    element :display_conditional_radio, '#conditional-content-display-conditional-field', visible: :all
    element :conditionals_container, '.conditionals'
    sections :conditionals, ConditionalSection, '.conditional'
    element :add_another_rule, :button, I18n.t('conditional_content.add_another_rule')
    element :update_button, :button, I18n.t('dialogs.button_update')

    section :error_summary, '.govuk-error-summary' do
      element :error_summary_title, '.govuk-error-summary__title', text: I18n.t('activemodel.errors.summary_title')
      element :component_error_message, :link, text: I18n.t('activemodel.errors.messages.blank', attribute: 'Component')
      element :unsupported_error_message, :link, text: I18n.t('activemodel.errors.models.component_expression.unsupported')
      element :same_page_error_message, :link, text: I18n.t('activemodel.errors.models.component_expression.same_page')
    end

    def first_conditional
      conditional(0)
    end

    def second_conditional
      conditional(1)
    end

    def conditional(index)
      conditionals[index]
    end
end
