require 'rails_helper'

RSpec.describe AnnouncementComponent, type: :component do
  let(:banner) { AnnouncementComponent.new }

  let(:announcement) do
    instance_double(
      Announcement,
      title: 'News',
      content: 'This is a [test announcement](https://example.com)'
    )
  end

  describe 'rendering the component' do
    before do
      allow(Announcement).to receive(:candidates).and_return(candidates)
      render_inline(banner)
    end

    context 'when there are no announcements' do
      let(:candidates) { [] }

      it 'does not render the notification banner' do
        expect(page).not_to have_css('div.govuk-notification-banner.mojf-announcement')
      end
    end

    context 'when there is an announcement' do
      let(:candidates) { [announcement] }

      it 'renders the expected notification banner markup' do
        expect(page).to have_css('div.govuk-notification-banner.mojf-announcement') do
          expect(page).to have_css('h2.govuk-notification-banner__title', text: 'News')
          expect(page).to have_css('div.govuk-notification-banner__content', text: 'This is a test announcement')
        end
      end

      it 'converts markdown to html' do
        expect(page).to have_css('div.govuk-notification-banner__content') do
          expect(page).to have_css('a[rel="external"]', text: 'test announcement')
          expect(page).to have_css('a[href="https://example.com"]')
        end
      end
    end
  end
end
