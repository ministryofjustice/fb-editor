class Questionnaire::BaseController < PermissionsController
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  skip_before_action :authorised_access, only: %i[index create]

  before_action :init_answers

  def index; end

  def create
    @form = form_name.new(answer_params)

    unless @form.valid?
      return render "questionnaire/#{controller_name}/index", status: :unprocessable_entity
    end

    update_session(answer_params)

    next_page = flow.next(page)

    if next_page
      if next_page == :gov_forms
        redirect_to send("questionnaire_#{next_page}_path")
      else
        redirect_to send("questionnaire_#{next_page}_index_path")
      end
    else
      redirect_to review_questionnaire_index_path
    end
  end

  private

  def init_answers
    session[:answers] ||= {}
    @answers = session[:answers].with_indifferent_access
  end

  def flow
    @flow ||= QuestionFlow.new(@answers)
  end

  def update_session(answer_params)
    session[:answers].merge! answer_params
  end
end
