class QuestionnaireFlow
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

  def initialize(answers)
    @answers = answers
  end

  def next(current)
    case current.to_sym
    when :get_started
      @answers['new_form_reason'] == Questionnaire::GetStartedForm::BUILDING ? :gov_forms : :great_choice
    when :gov_forms
      @answers['govuk_forms_ruled_out'] == 'true' ? :form_features : :continue
    when :continue
      @answers['continue_with_moj_forms'] == 'true' ? :new_form : :exit
    when :form_features
      :new_form
    when :new_form
      :requirements
    when :requirements
      nil
    when :great_choice
      nil
    when :exit
      nil
    end
  end

  def form_class(page)
    PAGE_CONFIG.dig(page.to_sym, :form)
  end

  def param_key(page)
    PAGE_CONFIG.dig(page.to_sym, :param_key)
  end
end
