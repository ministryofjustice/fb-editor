module QuestionnaireHelper
  def render_answers_list
    return content_tag(:ul) if session[:questionnaire_answers].blank?

    content_tag(:ul) do
      session[:questionnaire_answers].map { |q, a|
        content_tag(:li) do
          content_tag(:strong, "#{q}: ") + a.to_s
        end
      }.join.html_safe
    end
  end

  def set_form_defaults(form)
    form.attributes.each_key do |attribute|
      value = session.dig(:questionnaire_answers, attribute)
      form.public_send("#{attribute}=", value) if value.present?
    end
  end
end
