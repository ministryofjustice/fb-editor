class QuestionnaireController < PermissionsController
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  skip_before_action :authorised_access, only: %i[show update]

  before_action :init_answers

  def show
    render page
  end

  def update
    @form = form_name.new(answer_attributes)

    unless @form.valid?
      return render @page, status: :unprocessable_entity
    end

    update_session(answer_attributes)

    next_page = flow.next(@page)

    if next_page
      redirect_to questionnaire_path(next_page)
    else
      redirect_to review_questionnaire_index_path
    end
  end

  private

  def page
    @page ||= params[:id]
  end

  def init_answers
    session[:answers] ||= {}
    @answers = session[:answers].with_indifferent_access
  end

  def flow
    @flow ||= QuestionFlow.new(@answers)
  end

  def update_session(answer_attributes)
    session[:answers].merge! answer_attributes
  end

  def answer_attributes
    case page.to_sym
    when :get_started
      { new_form_reason: params[:new_form_reason] }
    when :gov_forms
      { govuk_forms_ruled_out: params[:govuk_forms_ruled_out] }
    end
  end

  def form_name
    case page.to_sym
    when :get_started
      Questionnaire::GetStartedForm
    when :gov_forms
      Questionnaire::GovForms
    end
  end
end
