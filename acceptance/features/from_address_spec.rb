require_relative '../spec_helper'

feature 'From address' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:configs) do
    {
      'default': {
        'email': I18n.t('default_values.service_email_from'),
        'link': I18n.t('activemodel.attributes.email_settings.from_address.link'),
        'warning': I18n.t('warnings.email_settings.default')
      },
      'pending': {
        'email': 'elrond@gmail.com',
        'link': I18n.t('activemodel.attributes.email_settings.from_address.pending_link'),
        'warning': I18n.t('warnings.email_settings.pending')
      }
    }
  end

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(name: service_name)
  end

  scenario 'from address settings page' do
    when_I_visit_the_from_address_settings_page
    then_I_should_see_the_from_address_settings_page
    then_I_should_see_the_from_address_defaults

    when_I_change_my_from_address('But we harfoots have each other')
    then_I_should_see_email_validation_error

    when_I_change_my_from_address('')
    then_I_should_see_the_from_address_defaults

    when_I_change_my_from_address(configs[:pending][:email])
    then_I_should_see_the_contact_us_message
    then_I_click_the_contact_us_link
  end

  ## From Address Settings page
  def then_I_should_see_the_from_address_settings_page
    expect(page).to have_content(I18n.t('settings.from_address.heading'))
    expect(page).to have_content(I18n.t('settings.from_address.description'))
    expect(page).to have_content(I18n.t('activemodel.attributes.from_address.from_address_hint'))
  end

  def then_I_should_see_the_from_address_defaults
    expect(page).to have_field(I18n.t('activemodel.attributes.from_address.email'), with: configs[:default][:email])
    expect(page).to have_content(I18n.t('warnings.from_address.settings.default'))
  end

  def then_I_should_see_the_contact_us_message
    expect(page).to have_content(I18n.t('settings.from_address.link_contact_us'))
  end

  def then_I_click_the_contact_us_link
    editor.click_link(I18n.t('settings.from_address.link_contact_us'))
    expect(current_url).to eq(I18n.t('settings.from_address.contact_url'))
  end

  def then_I_should_see_email_validation_error
    expect(page).to have_content(I18n.t('activemodel.errors.summary_title'))
    expect(page).to have_content(I18n.t('activemodel.errors.models.from_address.invalid'))
  end

  ## Send data by email page
  def then_I_should_see_the_send_data_by_email_page
    expect(page).to have_content(I18n.t('settings.collection_email.heading'))
    expect(page).to have_content(I18n.t('settings.form_analytics.test.description'))
    expect(page).to have_content(I18n.t('settings.form_analytics.live.description'))
    expect(page).to have_content(I18n.t('activemodel.attributes.email_settings.send_by_email_dev'))
    expect(page).to have_content(I18n.t('activemodel.attributes.email_settings.send_by_email_production'))
    expect(page).to have_button(I18n.t('actions.save'))
  end

  def then_I_should_see_the_send_data_by_email_from_address_warnings(status)
    configs[status].each do |key, value|
      expect(page).to have_content(value)
    end
  end
end
