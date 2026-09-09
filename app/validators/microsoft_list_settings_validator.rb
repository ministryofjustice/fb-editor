class MicrosoftListSettingsValidator < ActiveModel::Validator
  def validate(record)
    site_id = record.ms_site_id
    uuid_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

    if site_id.blank?
      record.errors.add(:ms_site_id, 'Enter a Teams site ID')
      return false
    end

    unless site_id.match?(uuid_regex)
      record.errors.add(:ms_site_id, 'Enter a valid Teams site ID')
      return false
    end

    true
  end
end
