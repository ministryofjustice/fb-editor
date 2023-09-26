class TeamEmailPrinter
  def call
    Rails.logger.info(user_ids)
  end

  private

  def user_ids
    User.all.map { |user| user.id if user.email.in?(team_emails) }.compact
  end

  def team_emails
    @team_emails ||= Rails.application.config.moj_forms_team
  end
end
