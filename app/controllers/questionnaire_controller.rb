class QuestionnaireController < PermissionsController
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  skip_before_action :authorised_access, only: %i[show update back_to_services]

  before_action :set_page, except: %i[back_to_services]
  before_action :init_questionnaire_answers

  def show
    @form = flow.form_class(@page).new
    render @page
  end

  def update
    @form = flow.form_class(@page).new(answer_attributes)

    return render @page, status: :unprocessable_entity unless @form.valid?

    persist_questionnaire_answers

    next_page = flow.next(@page)

    if next_page
      redirect_to questionnaire_path(next_page)
    else
      redirect_to review_questionnaire_index_path
    end
  end

  def back_to_services
    session.delete(:questionnaire_answers)
    redirect_to services_path
  end

  private

  def set_page
    @page = params[:id].to_sym
  end

  def init_questionnaire_answers
    session[:questionnaire_answers] ||= {}.with_indifferent_access
  end

  def persist_questionnaire_answers
    session[:questionnaire_answers].merge!(answer_attributes)
  end

  def flow
    @flow ||= QuestionnaireFlow.new(session[:questionnaire_answers])
  end

  def answer_attributes
    param_key = flow.param_key(@page)
    return {} unless param_key

    params.require(param_key).permit!
  end
end
