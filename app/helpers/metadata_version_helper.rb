module MetadataVersionHelper
  ACCEPTANCE_TEST_USER_ID = 'a5833e7a-a210-4447-904c-df050d198e33'.freeze
  ACCEPTANCE_TEST_FORMS = [
    'cd75ad76-1d4b-4ce5-8a9e-035262cd2683', # New Runner Service
    'e68dca75-20b8-468e-9436-e97791a914c5', # Branching Fixture 10 Service
    '759716eb-b4fb-413e-b883-f7016e2a9feb', # Save and Return v2 Service
    '11744bdf-86e3-4be3-b2cc-86434dc08ef2', # Conditional content Service
    '1ef15479-5a2c-4426-a5bf-54253031d9be', # API Submission JSON Output v2 Service
    '57497ef9-61cb-4579-ab93-f686e09d6936', # Smoke Tests V2
    '3d1cf5f3-47f3-4aeb-ae63-c2d15ce5378a', # External start page form
    '9a4e74e8-a1d7-4ce9-99ee-543f4cc3744f', # Welsh locale
    '5dc607a0-27b4-4e6b-ae5a-b23d73731ba6'  # Conditional content v2
  ].freeze

  private

  def get_version_metadata(publish_service)
    # get the latest version of the metadata because if the version id is missing
    # then the latest version would have been the one published before the
    # version_id column was added to the DB
    if publish_service.version_id.blank?
      return latest_version(publish_service.service_id)
    end

    version = MetadataApiClient::Version.find(
      service_id: publish_service.service_id,
      version_id: publish_service.version_id
    )
    version.metadata
  end

  def latest_version(service_id)
    MetadataApiClient::Service.latest_version(service_id)
  end

  def service_slug_from_name(version_metadata)
    service = MetadataPresenter::Service.new(version_metadata, editor: true)
    service.service_slug
  end

  def moj_forms_team_service_ids
    @moj_forms_team_service_ids ||= team_services.map(&:id) + ACCEPTANCE_TEST_FORMS
  end

  def team_services
    user_ids.map { |id| MetadataApiClient::Service.all(user_id: id) }.flatten
  end

  def user_ids
    User.all.filter_map { |user| user.id if user.email.in?(team_emails) }
  end

  def team_emails
    Rails.application.config.moj_forms_team
  end
end
