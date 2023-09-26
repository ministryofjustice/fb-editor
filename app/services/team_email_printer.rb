class TeamEmailPrinter
  def call
    Rails.logger.info(user_ids)
  end

  private

  def user_ids
    User.all.map { |user| user.id if user.email.in?(team_emails) }.compact
  end
end
