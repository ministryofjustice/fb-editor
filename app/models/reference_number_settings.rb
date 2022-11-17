class ReferenceNumberSettings
  include ActiveModel::Model

  attr_accessor :service_id,
                :reference_number,
                :deployment_environment

  validates :service_id, presence: true

  def reference_number_checked?
    enabled? || ServiceConfiguration.find_by(
      service_id: service_id
    ).try(:reference_number)
  end

  def enabled?
    reference_number == '1'
  end
end
