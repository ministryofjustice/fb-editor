class Questionnaire::GovFormsController < Questionnaire::BaseController
  def page
    :gov_forms
  end

  def answer_params
    { govuk_forms_ruled_out: params[:govuk_forms_ruled_out] }
  end

  def form_name
    Questionnaire::GovUkForm
  end
end
