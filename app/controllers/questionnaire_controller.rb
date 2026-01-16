class QuestionnaireController < PermissionsController
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  skip_before_action :authorised_access, only: %i[show update back_to_services]

  before_action :set_page, except: %i[back_to_services]
  before_action :init_answers

  PAGE_CONFIG = {
    get_started: {
      form: Questionnaire::GetStartedForm,
      param_key: :questionnaire_get_started_form
    },
    gov_forms: {
      form: Questionnaire::GovForms,
      param_key: :questionnaire_gov_forms
    },
    continue: {
      form: Questionnaire::ContinueForm,
      param_key: :questionnaire_continue_form
    },
    form_features: {
      form: Questionnaire::FormFeaturesForm,
      param_key: :questionnaire_form_features_form
    },
    new_form: {
      form: Questionnaire::NewFormForm,
      param_key: :questionnaire_new_form_form
    },
    requirements: {
      form: Questionnaire::Requirements
    },
    great_choice: {
      form: Questionnaire::GreatChoice
    },
    exit: {
      form: Questionnaire::Exit
    }
  }.freeze

  def show
    @form = form_class.new # (@answers)
    render @page
  end

  def update
    @form = form_class.new(answer_attributes)

    unless @form.valid?
      return render @page, status: :unprocessable_entity
    end

    persist_answers

    next_page = flow.next(@page)

    if next_page
      redirect_to questionnaire_path(next_page)
    else
      redirect_to review_questionnaire_index_path
    end
  end

  def back_to_services
    session.delete(:answers)
    redirect_to services_path
  end

  private

  def set_page
    @page = params[:id].to_sym
  end

  def init_answers
    session[:answers] ||= {}.with_indifferent_access
  end

  def persist_answers
    session[:answers].merge!(answer_attributes)
  end

  def flow
    @flow ||= QuestionnaireFlow.new(session[:answers])
  end

  def page_config
    PAGE_CONFIG.fetch(@page)
  end

  def form_class
    page_config[:form]
  end

  def answer_attributes
    return {} unless page_config[:param_key]

    params.require(page_config[:param_key]).permit!
  end
end
