module QuestionnaireHelper
  def render_answers_list
    return content_tag(:ul) if session[:answers].blank?

    content_tag(:ul) do
      session[:answers].map { |q, a|
        content_tag(:li) do
          content_tag(:strong, "#{q}: ") + a.to_s
        end
      }.join.html_safe
    end
  end
end
