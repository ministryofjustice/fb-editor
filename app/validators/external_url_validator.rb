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
  end
end
