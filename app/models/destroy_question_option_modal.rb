class DestroyQuestionOptionModal
  include ActiveModel::Model
  attr_accessor :service, :page, :question, :option, :pages

  delegate :expressions, :conditionals, :content_expressions, to: :service

  PARTIALS = {
    used_for_conditional_content?: 'delete_option_used_for_conditional_content',
    used_for_branching?: 'delete_option_used_for_branching',
    default?: 'delete_option'
  }.freeze

  def initialize(service:, page:, question:, option:)
    @service = service
    @page = page
    @question = question
    @option = option
    @partial = PARTIALS.select { |method_name, _| method(method_name).call.present? }.values.first
  end

  def to_partial_path
    "api/question_options/#{@partial}_modal"
  end

  private

  def used_for_conditional_content?
    return false unless ENV['CONDITIONAL_CONTENT'] == 'enabled'
    return false unless option.present?

    @pages = service.pages_with_conditional_content_for_question_option(option.uuid)
    @pages.any?
  end

  def used_for_branching?
    option.present? && expressions.map(&:field).include?(option.uuid)
  end

  def default?
    true
  end
end
