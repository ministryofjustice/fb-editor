class DestroyQuestionModal
  include ActiveModel::Model
  include ConfirmationEmailModalHelper

  attr_accessor :service, :page, :question

  delegate :expressions, :conditionals, :content_expressions, to: :service


  PARTIALS = { 
    used_for_conditional_content?: 'delete_question_used_for_conditional_content',
    used_for_branching?: 'delete_question_used_for_branching',
    used_for_confirmation_email?: 'delete_question_used_for_confirmation_email',
    default?: 'delete_question'
  }

  def to_partial_path
    result = PARTIALS.find do |method_name, _|
      method(method_name).call.present?
    end

    "api/questions/#{result[1]}_modal"
  end

  private

  def used_for_conditional_content?
    content_expressions.map(&:component).include?(question.uuid)
  end

  def used_for_branching?
    expressions.map(&:component).include?(question.uuid)
  end

  def used_for_confirmation_email?
    return unless confirmation_email_setting_checked?

    question.id.in?(confirmation_email_component_ids)
  end

  def default?
    true
  end
end
