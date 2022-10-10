class TestServicesConfigsRemover
  def call
    models.each do |model|
      model.where.not(service_id: moj_forms_team_service_ids).destroy_all
    end
  end

  private

  def moj_forms_team_service_ids
    @moj_forms_team_service_ids ||= team_services.map(&:id)
  end

  def team_services
    user_ids.map { |id| MetadataApiClient::Service.all(user_id: id) }.flatten
  end

  def user_ids
    User.all.select { |user| user.id if user.email.in?(team_emails) }.compact
  end

  def team_emails
    @team_emails ||= Rails.application.config.moj_forms_team
  end

  def models
    [ServiceConfiguration, SubmissionSetting, PublishService, FromAddress]
  end
end
