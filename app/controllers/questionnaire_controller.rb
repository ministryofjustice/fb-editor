class QuestionnaireController < PermissionsController
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  skip_before_action :authorised_access, only: %i[show update back_to_services]

  before_action :set_page, except: %i[back_to_services]
  before_action :init_answers

  PAGE_CONFIG = {
    get_started: {
      form: Questionnaire::GetStartedForm,
      attrs: ->(p) { { new_form_reason: p[:questionnaire_get_started_form][:new_form_reason] } }
    },
    gov_forms: {
      form: Questionnaire::GovForms,
      attrs: ->(p) { { govuk_forms_ruled_out: p[:questionnaire_gov_forms][:govuk_forms_ruled_out] } }
    },
    continue: {
      form: Questionnaire::ContinueForm,
      attrs: ->(p) { { continue_with_moj_forms: p[:questionnaire_continue_form][:continue_with_moj_forms] } }
    },
    form_features: {
      form: Questionnaire::FormFeaturesForm,
      attrs: lambda { |p|
        {
          required_moj_forms_features: p[:questionnaire_form_features_form][:required_moj_forms_features],
          govuk_forms_ruled_out_reason: p[:questionnaire_form_features_form][:govuk_forms_ruled_out_reason]
        }
      }
    },
    new_form: {
      form: Questionnaire::NewFormForm,
      attrs: lambda { |p|
        {
          estimated_page_count: p[:questionnaire_new_form_form][:estimated_page_count],
          estimated_first_year_submissions_count: p[:questionnaire_new_form_form][:estimated_first_year_submissions_count],
          submission_delivery_method: p[:questionnaire_new_form_form][:submission_delivery_method]
        }
      }
    },
    requirements: {
      form: Questionnaire::Requirements,
      attrs: nil
    },
    great_choice: {
      form: Questionnaire::GreatChoice,
      attrs: nil
    },
    exit: {
      form: Questionnaire::Exit,
      attrs: nil
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
    session[:answers] ||= {}
    @answers = session[:answers].with_indifferent_access
  end

  def persist_answers
    session[:answers].merge!(answer_attributes)
  end

  def flow
    @flow ||= QuestionnaireFlow.new(@answers)
  end

  def page_config
    PAGE_CONFIG.fetch(@page)
  end

  def form_class
    page_config[:form]
  end

  def answer_attributes
    page_config[:attrs].call(params)
  end
end
