class FormAnalyticsValidator < ActiveModel::Validator
  PREFIXES = { ua: 'UA-', gtm: 'GTM-', ga4: 'G-' }.freeze

  def validate(record)
    record.environments.each do |environment|
      next unless record.enabled?(environment)

      record.config_params.each do |name|
        attribute_name = :"#{name}_#{environment}"
        value = record.instance_param(attribute_name)
        next if value.blank? || value.upcase.starts_with?(PREFIXES[name])

        record.errors.add(
          attribute_name,
          I18n.t("activemodel.errors.models.form_analytics_settings.#{name}")
        )
      end
    end
  end
end
