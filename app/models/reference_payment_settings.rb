class ReferencePaymentSettings
  include ActiveModel::Model

  attr_accessor :service_id,
                :reference_number,
                :deployment_environment

  validates :service_id, presence: true

  def reference_number_checked?
    enabled? || ServiceConfiguration.exists?(service_id: service_id, name: 'REFERENCE_NUMBER')
  end

  def enabled?
    reference_number == '1'
  end

  def payment_link_checked?
    payment_enabled? || ServiceConfiguration.exists?(service_id: service_id, name: 'PAYMENT_LINK')
  end

  def payment_enabled?
    false
  end
end
