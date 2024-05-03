class AnnouncementComponent < ViewComponent::Base
  TURBO_FRAME_ID = 'announcement-notification'.freeze

  # rubocop:disable Layout/TrailingWhitespace
  erb_template <<~ERB
    <turbo-frame id="<%= TURBO_FRAME_ID %>">
      <div class="govuk-notification-banner mojf-announcement" role="region" 
           aria-labelledby="govuk-notification-banner-title" data-module="govuk-notification-banner">
        <div class="govuk-notification-banner__header">
          <h2 class="govuk-notification-banner__title" id="govuk-notification-banner-title">
            <%= banner_title %>
            <span class="mojf-announcement__dismiss-link">
              <% if @user %>
                <%= link_to dismiss_announcement_path(announcement), 'data-turbo-method': :put, 
                                     class: 'govuk-link govuk-link--inverse' do %>
                  <%=t('notification_banners.dismiss')%><span class="govuk-visually-hidden"><%= t('notification_banners.dismiss_assistive')%></span>
              <% end %>
              <% end %>
            </span>
          </h2>
        </div>
        <div class="govuk-notification-banner__content">
          <%= banner_content %>
        </div>
      </div>
    </turbo-frame>
  ERB
  # rubocop:enable Layout/TrailingWhitespace

  def initialize(announcement: nil, user: nil)
    @announcement = announcement
    @user = user
    super
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
