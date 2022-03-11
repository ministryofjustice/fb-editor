
class DestroyOptionModal
  include ActiveModel::Model
  attr_accessor :service, :page, :question, :option, :label

  delegate :expressions, :conditionals, to: :service

  def to_partial_path
    return 'api/options/cannot_delete_modal' if can_not_be_deleted?

    'api/options/destroy_message_modal'
  end

  private

  def can_not_be_deleted?
    option && expressions.map(&:field).include?(option.uuid)
  end
end
