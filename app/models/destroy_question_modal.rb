class DestroyQuestionModal
  include ActiveModel::Model
  include ConfirmationEmailModalHelper

  attr_accessor :service, :page, :question, :pages

  delegate :expressions, to: :service

  PARTIALS = {
    used_for_conditional_content?: 'delete_question_used_for_conditional_content',
    used_for_branching?: 'delete_question_used_for_branching',
    used_for_confirmation_email?: 'delete_question_used_for_confirmation_email',
    default?: 'delete_question'
  }.freeze

  def initialize(service:, page:, question:)
    @service = service
    @page = page
    @question = question
    @partial = PARTIALS.select { |method_name, _| method(method_name).call.present? }.values.first
  end

  def to_partial_path
    "api/questions/#{@partial}_modal"
  end

  private

  def used_for_conditional_content?
    return false unless ENV['CONDITIONAL_CONTENT'] == 'enabled'

    @pages = service.pages_with_conditional_content_for_question(question.uuid)
    @pages.any?
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
