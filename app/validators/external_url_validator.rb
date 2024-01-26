class ExternalUrlValidator < ActiveModel::Validator
  def validate(record)
    if record.url.blank?
      record.errors.add(
        :url,
        I18n.t(
          'activemodel.errors.models.external_url_validation.missing'
        )
      )
    end
    unless record.url =~ /gov.uk/
      record.errors.add(
        :url,
        I18n.t(
          'activemodel.errors.models.external_url_validation.invalid'
        )
      )
    end
  end
end
