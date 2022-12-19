class ReferencePaymentValidator < ActiveModel::Validator
  def validate(record)
    return unless record.payment_link_checked?

    unless record.reference_number_enabled?
      record.errors.add(:base, I18n.t('activemodel.errors.models.reference_payment_settings.reference_number_disabled'))
    end

    if reference_and_payment_checked_with_url_missing(record) || payment_link_checked_with_url_missing(record)
      record.errors.add(:base, I18n.t('activemodel.errors.models.reference_payment_settings.missing_payment_link'))
    end

    if record.payment_link_url.present? && !record.payment_link_url.start_with?(gov_uk_link)
      record.errors.add(:base, I18n.t('activemodel.errors.models.reference_payment_settings.invalid_payment_url', link_start_with: gov_uk_link))
    end
  end

  private

  def gov_uk_link
    I18n.t('activemodel.errors.models.reference_payment_settings.link_start_with')
  end

  def payment_link_checked_with_url_missing(record)
    record.payment_link_checked? && record.payment_link_url.blank?
  end

  def reference_and_payment_checked_with_url_missing(record)
    record.reference_number_enabled? && !record.payment_link_url_enabled?
  end
end