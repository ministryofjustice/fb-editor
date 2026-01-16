class Questionnaire::GetStartedController < Questionnaire::BaseController
  def page
    :get_started
  end

  def answer_params
    { new_form_reason: params[:new_form_reason] }
  end

  def form_name
    Questionnaire::GetStartedForm
  end
end
