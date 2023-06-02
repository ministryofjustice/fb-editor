class FormNameUrlSettings
  include ActiveModel::Model
  include MetadataVersion
  attr_accessor :service_id, :latest_metadata, :service_name, :service_slug

  MINIMUM = 3

  validates :service_name, :service_slug, presence: true
  validates :service_name, legacy_service_name: true
  validates :service_name, length: { minimum: MINIMUM, maximum: 150 }, allow_blank: true
  validates :service_slug, length: { minimum: MINIMUM, maximum: 57 }, allow_blank: true
  validates :service_slug, format: { with: /\A[a-zA-Z][\sa-z0-9-]*\z/ }, allow_blank: true
  validates :service_slug, format: { with: /\A\S+\Z/ }, allow_blank: true
  validates_with ServiceSlugValidator

  def create
    return false if invalid?

    version = MetadataApiClient::Version.create(
      service_id:,
      payload: metadata
    )

    if version.errors?
      errors.add(:base, :invalid, message: version.errors)
      false
    else
      @version = version
    end
  end

  def saved_service_name
    params(:service_name).presence || service_name
  end

  def saved_service_slug
    service_slug
  end

  def published_to_live?
    published_production&.last&.published?
  end

  private

  def params(setting_name)
    instance_variable_get(:"@#{setting_name}")
  end

  def metadata
    latest_metadata.merge(service_name:)
  end

  def published_production
    @published_production ||= PublishService.where(
      service_id:
    ).production
  end
end
