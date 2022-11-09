class ReferenceNumberSettings < ApplicationRecord
  include ActiveModel::Model
  attr_accessor :service_id, :enabled

  def enabled?
    public_send("enabled") == '1'
  end

  def check_enabled?
    enabled? || previously_configured?
  end

  private

  def previously_configured?
    # check database for existing config
    # SubmissionSetting.where(service_id: service_id).pick(:reference_number)
  end
end
