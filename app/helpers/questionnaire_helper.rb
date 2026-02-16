module QuestionnaireHelper
  def set_form_defaults(form)
    form.attributes.each_key do |attribute|
      value = session.dig(:questionnaire_answers, attribute)
      form.public_send("#{attribute}=", value) if value.present?
    end
  end
end
