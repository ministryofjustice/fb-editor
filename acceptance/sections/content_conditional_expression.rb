class ContentConditionalExpression < SitePrism::Section
      element :component_select, '.expression__component'
      element :operator_select, '.expression__operator'
      elements :operator_select_options, '.expression__operator option'
      element :answer_select, '.expression__answer'
      elements :answer_select_options, '.expression__answer option'
      element :delete_button, '.expression__remover'

      
    def operator_select_values
      operator_select_options.map{|option| option['value'] }
    end

    def answer_select_labels
      answer_select_options.map{|option| option.text }
    end
end
