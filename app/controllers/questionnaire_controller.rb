class QuestionnaireController < PermissionsController
  skip_before_action :authorised_access, only: %i[show update review]

  before_action :init_answers

  def show
    @question = params[:id]&.to_sym || flow.first
  end

  def update
    @question = params[:id].to_sym
    @answers[@question] = params[:answer]

    @form = Questionnaire::GetStartedForm.new(@answers, @question)

    unless @form.valid?
      return render :show, status: :unprocessable_entity
    end

    next_question = flow.next(@question)

    if next_question
      redirect_to questionnaire_path(next_question)
    else
      redirect_to review_questionnaire_index_path
    end
  end

  def review; end

  def submit
    session.delete(:answers)
    redirect_to questionnaire_path(:q1)
  end

  private

  def init_answers
    session[:answers] ||= {}
    @answers = session[:answers] # .with_indifferent_access
  end

  def flow
    @flow ||= QuestionFlow.new(@answers)
  end
end
