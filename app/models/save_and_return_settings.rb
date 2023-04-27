class SaveAndReturnSettings
  include ActiveModel::Model

  attr_accessor :service_id,
                :save_and_return

  validates :service_id, presence: true

  def save_and_return_checked?
    return ServiceConfiguration.exists?(service_id:, name: 'SAVE_AND_RETURN') if save_and_return.blank?

    save_and_return_enabled?
  end

  def save_and_return_enabled?
    save_and_return == '1'
  end
end
