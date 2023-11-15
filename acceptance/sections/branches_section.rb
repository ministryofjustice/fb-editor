require_relative './conditional_section'

class BranchesSection < SitePrism::Section
    element :conditionals_container, '.conditionals'
    sections :conditionals, ConditionalSection, '.conditional'
    element :add_another_rule, :button, I18n.t('conditional_content.add_another_rule')

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
