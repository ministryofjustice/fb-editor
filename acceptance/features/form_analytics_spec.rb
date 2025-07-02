require_relative '../spec_helper'

feature 'Form analytics configuration' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:error_messages) do
    [
      I18n.t('activemodel.errors.models.form_analytics_settings.gtm'),
      I18n.t('activemodel.errors.models.form_analytics_settings.ga4')
    ]
  end

  # background do
  #   given_I_am_logged_in
  #   given_I_have_a_service_fixture(name: service_name)
  #   when_I_visit_the_form_analytics_page
  #   then_I_should_see_the_settings_configuration
  # end

  # shared_examples 'a form analytics settings' do
  #   scenario 'configuring form analytics settings' do
  #     when_I_enable_the_analytics(environment)
  #     then_I_should_see_the_account_ids_fields(environment)

  #     click_button(I18n.t('actions.save'))
  #     then_I_should_see_error_messages([I18n.t('activemodel.errors.models.form_analytics_settings.blank')])

  #     then_I_should_see_the_account_ids_fields(environment)
  #     and_I_set_the_analytics_tracking_id("gtm_#{environment}", invalid_ids["gtm_#{environment}"])
  #     and_I_set_the_analytics_tracking_id("ga4_#{environment}", invalid_ids["ga4_#{environment}"])
  #     click_button(I18n.t('actions.save'))
  #     then_I_should_see_error_messages(error_messages)

  #     and_I_set_the_analytics_tracking_id("gtm_#{environment}", valid_ids["gtm_#{environment}"])
  #     and_I_set_the_analytics_tracking_id("ga4_#{environment}", valid_ids["ga4_#{environment}"])
  #     click_button(I18n.t('actions.save'))
  #     then_I_should_see_no_error_message
  #     then_I_should_see_my_saved_ids(environment)

  #     when_I_disable_the_analytics(environment)
  #     click_button(I18n.t('actions.save'))

  #     when_I_enable_the_analytics(environment)
  #     then_I_should_see_the_account_ids_fields(environment)
  #     then_I_should_not_see_my_saved_ids
  #   end
  # end

  # context 'Test environment' do
  #   let(:environment) { 'test' }
  #   let(:invalid_ids) do
  #     {
  #       'gtm_test'=> 'real',
  #       'ga4_test' => 'ids'
  #     }
  #   end
  #   let(:valid_ids) do
  #     {
  #       'gtm_test' => 'GTM-12345',
  #       'ga4_test' => 'G-12345'
  #     }
  #   end

  #   it_behaves_like 'a form analytics settings'
  # end

  # context 'Live environment' do
  #   let(:environment) { 'live' }
  #   let(:invalid_ids) do
  #     {
  #       'gtm_live'=> 'fake',
  #       'ga4_live' => 'analytics'
  #     }
  #   end
  #   let(:valid_ids) do
  #     {
  #       'gtm_live' => 'GTM-67890',
  #       'ga4_live' => 'G-67890'
  #     }
  #   end

  #   it_behaves_like 'a form analytics settings'
  # end

  def when_I_visit_the_form_analytics_page
    page.find(:css, '#main-content', visible: true)
    editor.click_link(I18n.t('settings.name'))
    expect(page).to have_content(I18n.t('settings.form_analytics.lede'))
    editor.click_link(I18n.t('settings.form_analytics.heading'))
  end

  def when_I_enable_the_analytics(environment)
    page.find(:css, "input#form_analytics_settings_enabled_#{environment}", visible: false).set(true)
  end

  def when_I_disable_the_analytics(environment)
    page.find(:css, "input#form_analytics_settings_enabled_#{environment}", visible: false).set(false)
  end

  def and_I_set_the_analytics_tracking_id(id, value)
    input_element = page.find(:css, "input#form_analytics_settings_#{id}")
    input_element.set(value)
  end

  def then_I_should_see_the_settings_configuration
    expect(page).to have_content(I18n.t('settings.form_analytics.heading'))
    expect(page).to have_content(I18n.t('settings.form_analytics.description'))
    expect(page).to have_content(I18n.t('settings.form_analytics.test.heading'))
    expect(page).to have_content(I18n.t('settings.form_analytics.test.description'))
    expect(page).to have_content(I18n.t('settings.form_analytics.live.heading'))
    expect(page).to have_content(I18n.t('settings.form_analytics.live.description'))
  end

  def then_I_should_see_the_account_ids_fields(environment)
    expect(page).to have_content(I18n.t('settings.form_analytics.details_hint'))
    expect(page).to have_content(I18n.t('activemodel.attributes.form_analytics_settings.gtm'))
    expect(page).to have_content(I18n.t('activemodel.attributes.form_analytics_settings.gtm_hint'))
    expect(page).to have_content(I18n.t('activemodel.attributes.form_analytics_settings.ga4'))
    expect(page).to have_content(I18n.t('activemodel.attributes.form_analytics_settings.ga4_hint'))
  end

  def then_I_should_see_error_messages(messages)
    page.find(:css, '#main-content', visible: true)
    expect(page).to have_content(I18n.t('activemodel.errors.summary_title'))
    messages.each { |message| expect(page).to have_content(message) }
  end

  def then_I_should_see_no_error_message
    page.find(:css, '#main-content', visible: true)
    expect(page).to_not have_content(I18n.t('activemodel.errors.summary_title'))
  end

  def then_I_should_see_my_saved_ids(environment)
    page.find(:css, '#main-content', visible: true)
    page.find(:css, "#form_analytics_settings_#{environment}")
        .find(:css, 'span', text: I18n.t('settings.form_analytics.details')).click

    valid_ids.each do |id, value|
      input_element = page.find(:css, "input#form_analytics_settings_#{id}")
      expect(input_element.value).to eq(value)
    end
  end

  def then_I_should_not_see_my_saved_ids
    page.find(:css, '#main-content', visible: true)
    valid_ids.each do |id, value|
      input_element = page.find(:css, "input#form_analytics_settings_#{id}")
      expect(input_element.value).to_not eq(value)
    end
  end
end
