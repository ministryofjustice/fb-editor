require_relative '../spec_helper'

feature 'External start page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:start_page_menu_items) do
    [
      I18n.t('actions.edit_page'),
      I18n.t('actions.preview_page'),
      I18n.t('actions.enable_external_start_page')
    ]
  end

  let(:external_start_page_menu_items) do
    [
      I18n.t('actions.edit_external_start_page'),
      I18n.t('actions.preview_external_start_page'),
      I18n.t('actions.disable_external_start_page')
    ]
  end

  let(:start_page) { 'Service name goes here' }

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(name: service_name)
  end

  scenario 'set external start page' do
    and_I_click_on_the_page_menu(start_page)
    then_I_should_see_the_expected_menu_items(start_page, start_page_menu_items)
    and_I_click_on_use_external_start_page
    then_I_should_see_the_external_start_page_modal
    and_I_add_a_url('not-valid.co.uk')
    and_I_confirm_url
    then_I_should_see_an_error_message(I18n.t('activemodel.errors.models.external_url_validation.invalid'))
    and_I_re_enter_a_url('')
    and_I_confirm_url
    then_I_should_see_an_error_message(I18n.t('activemodel.errors.models.external_url_validation.missing'))
    and_I_re_enter_a_url('gov.uk')
    and_I_confirm_url
    then_I_should_see_the_external_start_page_is_set
  end

  scenario 'preview external start page' do
    and_I_click_on_the_page_menu(start_page)
    then_I_should_see_the_expected_menu_items(start_page, start_page_menu_items)
    and_I_click_on_use_external_start_page
    then_I_should_see_the_external_start_page_modal
    and_I_add_a_url('gov.uk')
    and_I_confirm_url
    then_I_should_see_the_external_start_page_is_set
    and_I_click_on_the_external_start_page_menu
    then_I_should_see_the_expected_menu_items(start_page, external_start_page_menu_items)
    and_I_click_on_preview_external_start_page
    then_I_should_see_the_preview_external_start_page_modal
    new_window = window_opened_by do
      click_preview_external_start_page
    end
    within_window new_window do
      assert_current_path 'https://www.gov.uk/'
    end 
  end

  def and_I_click_on_use_external_start_page
    page.click_on I18n.t('actions.enable_external_start_page')
  end

  def and_I_click_on_preview_external_start_page
    page.click_on I18n.t('actions.preview_external_start_page')
  end

  def then_I_should_see_the_external_start_page_modal
    expect(page).to have_content(I18n.t('external_start_page_url.title'))
    expect(page).to have_content(I18n.t('external_start_page_url.content'))
    expect(page).to have_content(I18n.t('external_start_page_url.help_link_text'))
  end

  def then_I_should_see_the_preview_external_start_page_modal
    expect(page).to have_content(I18n.t('external_start_page_url.preview.title'))
    expect(page).to have_content(I18n.t('external_start_page_url.preview.content_one'))
    expect(page).to have_content(I18n.t('external_start_page_url.preview.confirm'))
  end

  def and_I_add_a_url(text)
    page.first('#external-start-page-url-url-field').set text
  end

  def and_I_re_enter_a_url(text)
    page.find('#external-start-page-url-url-field-error').set text
  end

  def and_I_confirm_url
    page.click_button I18n.t('external_start_page_url.confirm')
  end

  def click_preview_external_start_page
    page.click_link I18n.t('external_start_page_url.preview.confirm')
  end

  def then_I_should_see_an_error_message(error_message)
    expect(page).to have_content(error_message)
  end

  def then_I_should_see_the_expected_menu_items(flow_title, expected_menu_items)
    items = find("ul[data-title='#{flow_title}']").all('[role="menuitem"]').map(&:text)
    expect(items).to eq(expected_menu_items)
  end

  def then_I_should_see_the_external_start_page_is_set
    visit current_path
    sleep 1
    expect(page).to have_content(I18n.t('external_start_page_url.link'))
  end
end
