class DestroyQuestionModal
  include ActiveModel::Model
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
    return if confirmation_email_component_id.nil?

    confirmation_email_component_id.decrypt_value.include?(question.id)
  end

  def confirmation_email_component_id
    @confirmation_email_component_id ||= ServiceConfiguration.find_by(
      service_id: service.service_id,
      name: 'CONFIRMATION_EMAIL_COMPONENT_ID'
    )
  end
end
