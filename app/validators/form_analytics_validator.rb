class FormAnalyticsValidator < ActiveModel::Validator
  PREFIXES = { ua: 'UA-', gtm: 'GTM-', ga4: 'G-' }.freeze

  def validate(record)
    record.config_params.each do |name|
      value = record.public_send(name)
      next if value.blank? || value.upcase.starts_with?(PREFIXES[name])

      record.errors.add(
        name,
        I18n.t("activemodel.errors.models.form_analytics_settings.#{name}")
      )
    end
  end
end
