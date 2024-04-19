require 'rails_helper'

RSpec.describe 'Announcements', type: :request do
  let(:current_user) { create(:user) }

  before do
    allow_any_instance_of(
      ApplicationController
    ).to receive(:require_user!).and_return(true)

    allow_any_instance_of(ServicesController).to receive(:services).and_return([])
    allow_any_instance_of(PermissionsController).to receive(:current_user).and_return(current_user)
  end

  describe 'when there are no announcements' do
    before do
      get services_path
    end

    it 'responds successfully' do
      expect(response.status).to be(200)
    end

    it 'does not have an announcement' do
      assert_select 'turbo-frame#announcement-notification', count: 0
    end
  end

  describe 'when there is an announcement' do
    let!(:announcement) { create(:announcement) }

    it 'shows the announcement' do
      get services_path

      assert_select 'turbo-frame#announcement-notification' do
        assert_select 'div.govuk-notification-banner.mojf-announcement' do
          assert_select 'h2.govuk-notification-banner__title', text: /News/ do
            assert_select 'span.mojf-announcement__dismiss-link' do
              assert_select 'a[data-turbo-method="put"].govuk-link--inverse', text: /Dismiss/
              assert_select "a[href='#{dismiss_announcement_path(announcement)}']"
            end
          end
          assert_select 'div.govuk-notification-banner__content', text: 'This is a test announcement' do
            assert_select 'a[rel="external"]', text: 'test announcement'
            assert_select 'a[href="https://example.com"]'
          end
        end
      end
    end

    it 'dismisses the announcement and does not show again' do
      put dismiss_announcement_path(announcement)
      assert_select 'turbo-frame#announcement-notification', count: 0

      get services_path
      assert_select 'turbo-frame#announcement-notification', count: 0
    end
  end
end
