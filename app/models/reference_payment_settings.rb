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
    return ServiceConfiguration.exists?(service_id: service_id, name: 'REFERENCE_NUMBER') if reference_number.blank?

    reference_number_enabled?
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
    return ServiceConfiguration.find_by(service_id: service_id, name: 'PAYMENT_LINK')&.decrypt_value if payment_link_url.nil?

    valid_payment_link_url
  end

  def payment_link_has_been_checked?
    return SubmissionSetting.find_by(
      service_id: service_id
    ).try(:payment_link?) if payment_link.nil?

    payment_link_checked?
  end

  def valid_payment_link_url
    payment_link_url.strip
  end
end
