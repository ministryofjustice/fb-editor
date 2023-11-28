class ExpressionSection < SitePrism::Section
      element :question_label, '.conditional__question label'
      element :component_select, '.expression__component'
      element :operator_select, '.expression__operator'
      elements :operator_select_options, '.expression__operator option'
      element :answer_select, '.expression__answer'
      elements :answer_select_options, '.expression__answer option'
      element :delete_button, '.expression__remover'
      element :unsupported_error, '.expression__error[data-error-type="unsupported"]'
      element :same_page_error, '.expression__error[data-error-type="samepage"]'


    def operator_select_values
      operator_select_options.map{|option| option['value'] }
    end

    def answer_select_labels
      answer_select_options.map{|option| option.text }
    end
end
