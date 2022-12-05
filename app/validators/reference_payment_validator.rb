class ReferencePaymentValidator < ActiveModel::Validator
  def validate(record)
    if !record.reference_number_enabled? && record.payment_link_checked?
      record.errors.add(:base, I18n.t('activemodel.errors.models.reference_payment_settings.reference_number_disabled'))
    end

    if record.reference_number_enabled? && record.payment_link_checked? && !record.payment_link_url_enabled?
      record.errors.add(:base, I18n.t('activemodel.errors.models.reference_payment_settings.missing_payment_link'))
    end

    if record.payment_link_checked? && !record.payment_link_url.start_with?(I18n.t('activemodel.errors.models.reference_payment_settings.link_start_with'))
      record.errors.add(:base, I18n.t('activemodel.errors.models.reference_payment_settings.invalid_payment_url'))
    end

    if record.payment_link_checked? && record.payment_link_url.blank?
      record.errors.add(:base, I18n.t('activemodel.errors.models.reference_payment_settings.missing_payment_link'))
    end
  end
end
