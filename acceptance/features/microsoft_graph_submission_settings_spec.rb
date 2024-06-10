require_relative '../spec_helper'

feature 'Submission email' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:start_page) { 'Service name goes here' }

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(name: service_name)
  end

  shared_examples 'ms graph submission settings page' do
    scenario 'loading the settings page' do
      when_I_visit_the_ms_graph_submission_settings_page
      then_I_should_see_the_ms_graph_submission_settings_page(environment)
      when_I_click_save(environment)
      then_I_should_see_validation
    end
  end

  context 'when dev environment' do
    let(:environment) { 'dev' }

    it_behaves_like 'ms graph submission settings page'
  end

  context 'when production environment' do
    let(:environment) { 'production' }

    it_behaves_like 'ms graph submission settings page'
  end

  def when_I_visit_the_ms_graph_submission_settings_page
    page.find(:css, '#main-content', visible: true)
    editor.click_link(I18n.t('settings.name'))
    expect(page).to have_content(I18n.t('settings.ms_list.heading'))
    expect(page).to have_content(I18n.t('settings.ms_list.lede'))
    editor.click_link(I18n.t('settings.ms_list.heading'))
  end

  def then_I_should_see_the_ms_graph_submission_settings_page(environment)
    expect(page).to have_content(I18n.t('settings.ms_list.heading'))
    expect(page).to have_content(I18n.t('settings.ms_list.lede'))
    expect(page).to have_content(I18n.t("publish.#{environment}.heading"))
    expect(page).to have_content(I18n.t("publish.#{environment}.description"))
    within( "#ms-list-setting-#{environment}") do
      expect(page).to have_button(I18n.t("actions.saved"))
    end
  end

  def when_I_click_save(environment)
    if environment == 'dev'
      click_button(I18n.t('settings.submission.dev.save_button'))
    else
      click_button(I18n.t('settings.submission.production.save_button'))
    end
  end

  def then_I_should_see_validation
    expect(page).to have_content("Your answer for 'Ms site' cannot be blank.")
  end
end