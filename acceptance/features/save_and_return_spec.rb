require_relative '../spec_helper'

feature 'Save and Return page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:start_page) { 'Service name goes here' }
  let(:save_and_return_checkbox) { 'input#save-and-return-settings-save-and-return-1-field' }

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(name: service_name)
    when_I_visit_the_save_and_return_page
    then_I_should_see_the_save_and_return_settings_page
  end

  scenario 'when I enable and disable save and return' do
    with_setting(save_and_return_checkbox, true)
    click_button(I18n.t('actions.save'))
    then_checkbox_should_remain_checked(save_and_return_checkbox, true)

    with_setting(save_and_return_checkbox, false)
    click_button(I18n.t('actions.save'))
    then_checkbox_should_remain_checked(save_and_return_checkbox, false)
  end

  ## Save and Return Settings Page
  def when_I_visit_the_save_and_return_page
    page.find(:css, '#main-content', visible: true)
    editor.click_link(I18n.t('settings.name'))
    expect(page).to have_content(I18n.t('settings.save_and_return.lede'))
    editor.click_link(I18n.t('settings.save_and_return.heading'))
  end

  def then_I_should_see_the_save_and_return_settings_page
    expect(page).to have_content(I18n.t('settings.save_and_return.heading'))
    expect(page).to have_content(I18n.t('settings.save_and_return.description'))
  end

  def then_checkbox_should_remain_checked(attribute, checked)
    element = find(attribute, visible: false)
    expect(element.checked?).to eq(checked)
  end

  def with_setting(setting, value)
    page.find(:css, setting, visible: false).set(value)
  end
end
