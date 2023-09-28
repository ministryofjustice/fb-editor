class DestroyQuestionOptionModal
  include ActiveModel::Model
  attr_accessor :service, :page, :question, :option, :label

  delegate :expressions, :conditionals, :content_expressions, to: :service

  PARTIALS = {
    used_for_conditional_content?: 'delete_option_used_for_conditional_content',
    used_for_branching?: 'delete_option_used_for_branching',
    default?: 'delete_option'
  }.freeze

  def to_partial_path
    result = PARTIALS.find do |method_name, _|
      method(method_name).call.present?
    end

    "api/question_options/#{result[1]}_modal"
  end

  private

  def used_for_conditional_content?
    return false unless ENV['CONDITIONAL_CONTENT'] == 'enabled'

    option.present? && content_expressions.map(&:field).include?(option.uuid)
  end

  def used_for_branching?
    option.present? && expressions.map(&:field).include?(option.uuid)
  end

  def default?
    true
  end
end
