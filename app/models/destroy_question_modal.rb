class DestroyQuestionModal
  include ActiveModel::Model
  attr_accessor :service, :page, :question

  delegate :expressions, :conditionals, to: :service

  def to_partial_path
    return 'api/questions/cannot_delete_modal' if can_not_be_deleted?

    'api/questions/destroy_message_modal'
  end

  private

  def can_not_be_deleted?
    expressions.map(&:component).include?(question.uuid)
  end
end
