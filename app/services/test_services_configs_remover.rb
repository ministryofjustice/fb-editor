class TestServicesConfigsRemover
  # new-runner-acceptance-tests and Acceptance Tests - Branching Fixture 10 service IDs
  RUNNER_ACCEPTANCE_TEST_FORMS = %w[
    cd75ad76-1d4b-4ce5-8a9e-035262cd2683
    e68dca75-20b8-468e-9436-e97791a914c5
  ].freeze

  def call
    models.each do |model|
      model.where.not(service_id: moj_forms_team_service_ids).destroy_all
    end
  end

  private

  def moj_forms_team_service_ids
    @moj_forms_team_service_ids ||= team_services.map(&:id).reject { |id| id.in?(RUNNER_ACCEPTANCE_TEST_FORMS) }
  end

  def team_services
    user_ids.map { |id| MetadataApiClient::Service.all(user_id: id) }.flatten
  end

  def user_ids
    User.all.map { |user| user.id if user.email.in?(team_emails) }.compact
  end

  def team_emails
    @team_emails ||= Rails.application.config.moj_forms_team
  end

  def models
    [ServiceConfiguration, SubmissionSetting, PublishService, FromAddress]
  end
end
