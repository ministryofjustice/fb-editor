class AnnouncementComponent < ViewComponent::Base
  def initialize(announcement = nil)
    @announcement = announcement
    super
  end

  def render?
    FeatureFlags.announcements.enabled? && announcement.present?
  end

  def call
    govuk_notification_banner(title_text:, text:, classes:)
  end

  private

  def announcement
    @announcement ||= Announcement.candidates.first
  end

  def title_text
    announcement.title
  end

  def text
    Govspeak::Document.new(
      announcement.content
    ).to_html.html_safe
  end

  def classes
    %w[mojf-announcement].freeze
  end
end
