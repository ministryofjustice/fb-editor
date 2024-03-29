module ContentSubstitutorHelper
  def content_substitutor
    @content_substitutor ||= ContentSubstitutor.new(
      service_name: service.service_name,
      reference_number_enabled: reference_number_enabled?,
      payment_link_enabled: payment_link_enabled?
    )
  end

  def reference_number_enabled?
    ServiceConfiguration.where(
      service_id: service.service_id,
      name: 'REFERENCE_NUMBER'
    ).present?
  end

  def payment_link_enabled?
    SubmissionSetting.find_by(
      service_id: service.service_id,
      deployment_environment: 'dev'
    ).try(:payment_link?)
  end
end
