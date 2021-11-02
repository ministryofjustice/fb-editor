require_relative '../spec_helper'

feature 'Branching errors' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:page_url) { 'palpatine' }

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'when visiting the publishing page' do
    when_I_visit_the_publishing_page
    then_I_should_be_on_the_publishing_page
  end

  def when_I_visit_the_publishing_page
    editor.publishing_link.click
  end

  def then_I_should_be_on_the_publishing_page
    expect(editor.question_heading.first.text).to eq(I18n.t('publish.heading'))
    buttons_text = page.all(:css, 'input.fb-govuk-button', visible: false).map(&:value)
    expect(buttons_text).to include(I18n.t('publish.test.button'))
    expect(buttons_text).to include(I18n.t('publish.live.button'))
  end
end
