class ReferencePaymentValidator < ActiveModel::Validator
  def validate(record)
    return unless record.payment_link_checked?

    unless record.reference_number_enabled?
      record.errors.add(
        :base,
        I18n.t('activemodel.errors.models.reference_payment_settings.reference_number_disabled')
      )
    end

    if record.payment_link_url.blank?
      record.errors.add(
        :base,
        I18n.t('activemodel.errors.models.reference_payment_settings.missing_payment_link')
      )
    end

    if record.payment_link_url.present? && !record.payment_link_url.start_with?(gov_uk_link)
      record.errors.add(
        :base,
        I18n.t(
          'activemodel.errors.models.reference_payment_settings.invalid_payment_url',
          link_start_with: gov_uk_link
        )
      )
    end
  end

  private

  def gov_uk_link
    I18n.t('activemodel.errors.models.reference_payment_settings.link_start_with')
  end
end
