class AnnouncementComponent < ViewComponent::Base
  TURBO_FRAME_ID = 'announcement-notification'.freeze

  def initialize(announcement: nil, user: nil)
    @announcement = announcement
    @user = user
    super()
  end

  def render?
    announcement.present? &&
      announcement.user_dismissals.exclude?(@user)
  end

  private

  def announcement
    @announcement ||= Announcement.candidates.first
  end

  def banner_title
    announcement.title
  end

  def banner_content
    Govspeak::Document.new(
      announcement.content
    ).to_html.html_safe
  end
end
