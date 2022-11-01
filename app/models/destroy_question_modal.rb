class DestroyQuestionModal
  include ActiveModel::Model
  include ConfirmationEmailModalHelper

  attr_accessor :service, :page, :question

  delegate :expressions, :conditionals, to: :service

  def to_partial_path
    return 'api/questions/cannot_delete_modal' if can_not_be_deleted?
    return 'api/questions/cannot_delete_confirmation_email_modal' if used_in_confirmation_email?

    'api/questions/destroy_message_modal'
  end

  private

  def can_not_be_deleted?
    expressions.map(&:component).include?(question.uuid)
  end

  def used_in_confirmation_email?
    return unless confirmation_email_setting_checked?

    question.id.in?(confirmation_email_component_ids)
  end
end
