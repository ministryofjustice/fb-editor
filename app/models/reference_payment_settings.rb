class ReferencePaymentSettings
  include ActiveModel::Model

  attr_accessor :service_id,
                :reference_number,
                :payment_link,
                :payment_link_url,
                :deployment_environment

  validates :service_id, presence: true
  validates_with ReferencePaymentValidator

  def reference_number_checked?
    reference_number_enabled? || ServiceConfiguration.exists?(service_id: service_id, name: 'REFERENCE_NUMBER')
  end

  def reference_number_enabled?
    reference_number == '1'
  end

  def payment_link_url_enabled?
    payment_link_url_present? || ServiceConfiguration.exists?(service_id: service_id, name: 'PAYMENT_LINK')
  end

  # rubocop:disable Rails/Delegate
  def payment_link_url_present?
    payment_link_url.present?
  end
  # rubocop:enable Rails/Delegate

  def payment_link_checked?
    payment_link == '1'
  end

  def saved_payment_link_url
    @saved_payment_link_url ||= (ServiceConfiguration.find_by(service_id: service_id, name: 'PAYMENT_LINK').decrypt_value if ServiceConfiguration.exists?(service_id: service_id, name: 'PAYMENT_LINK'))
  end
end
