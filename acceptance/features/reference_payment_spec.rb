require_relative '../spec_helper'

feature 'Reference Payment Page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:start_page) { 'Service name goes here' }
  let(:payment_link_checkbox) { 'input#reference-payment-settings-payment-link-1-field' }
  let(:payment_link_field) { 'input#reference-payment-settings-payment-link-url-field' }
  let(:reference_number_checkbox) { 'input#reference-payment-settings-reference-number-1-field' }
  let(:payment_link_label) { I18n.t('settings.payment_link.checkbox_label') }
  let(:valid_url) { I18n.t('activemodel.errors.models.reference_payment_settings.link_start_with') }
  let(:confirmation_page_payment_text) { "You still need to pay\nYour reference number is:" }
  let(:confirmation_warning_title) { I18n.t('settings.reference_number.confirmation_email_warning.title') }

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(name: service_name)
    when_I_visit_the_reference_payment_page
    then_I_should_see_the_payment_link_settings_configuration
  end

  scenario 'enable reference number only' do
    with_setting(reference_number_checkbox, true)
    click_button(I18n.t('actions.save'))
    then_I_should_not_see_my_content(I18n.t('activemodel.errors.summary_title'))
    expect(page).to have_css('.govuk-notification-banner__content', text: confirmation_warning_title)
    then_checkbox_should_remain_checked(reference_number_checkbox)

    then_I_add_a_page_with_email_component
    when_I_visit_the_confirmation_email_settings_page
    when_I_enable_confirmation_email('dev')
    then_I_add_a_reply_to_email('iorek.byrnison@digital.justice.gov.uk', 'dev')
    click_button(I18n.t('settings.submission.dev.save_button'))
    when_I_enable_confirmation_email('production')
    then_I_add_a_reply_to_email('iorek.byrnison@digital.justice.gov.uk', 'production')
    click_button(I18n.t('settings.submission.production.save_button'))
    when_I_visit_the_reference_payment_page
    expect(page).to_not have_css('.govuk-notification-banner__content', text: confirmation_warning_title)
  end

  scenario 'configure payment link settings without reference number' do
    with_setting(payment_link_checkbox, true)
    then_I_should_see_text(payment_link_label)
    with_setting(payment_link_field, valid_url)
    click_button(I18n.t('actions.save'))
    then_I_should_see_text(I18n.t('activemodel.errors.models.reference_payment_settings.reference_number_disabled'))
    then_checkbox_should_remain_checked(payment_link_checkbox)
  end

  scenario 'configure payment link settings without url' do
    with_setting(reference_number_checkbox, true)
    with_setting(payment_link_checkbox, true)
    then_I_should_see_text(payment_link_label)
    click_button(I18n.t('actions.save'))
    then_I_should_see_text(I18n.t('activemodel.errors.models.reference_payment_settings.missing_payment_link'))
    then_checkbox_should_remain_checked(reference_number_checkbox)
    then_checkbox_should_remain_checked(payment_link_checkbox)
  end

  scenario 'payment links with invalid url' do
    with_setting(reference_number_checkbox, true)
    with_setting(payment_link_checkbox, true)
    then_I_should_see_text(payment_link_label)
    with_setting(payment_link_field, 'dummy-url.com')
    click_button(I18n.t('actions.save'))
    then_I_should_see_text(
      I18n.t(
        'activemodel.errors.models.reference_payment_settings.invalid_payment_url',link_start_with: valid_url
      )
    )
    then_checkbox_should_remain_checked(reference_number_checkbox)
    then_checkbox_should_remain_checked(payment_link_checkbox)
  end

  xscenario 'email body in confirmation email settings page updates correctly' do
    with_setting(reference_number_checkbox, true)
    with_setting(payment_link_checkbox, true)
    then_I_should_see_text(payment_link_label)
    with_setting(payment_link_field, valid_url)
    click_button(I18n.t('actions.save'))
    then_I_add_a_page_with_email_component
    when_I_visit_the_confirmation_email_settings_page
    when_I_enable_confirmation_email('dev')
    expect(page).to have_content('{{reference_number}}')
    expect(page).to have_content('{{payment_link}}')
    
    then_I_should_be_warned_when_leaving_the_page

    when_I_visit_the_reference_payment_page
    with_setting(payment_link_checkbox, false)
    click_button(I18n.t('actions.save'))
    when_I_visit_the_confirmation_email_settings_page
    when_I_enable_confirmation_email('dev')
    expect(page).to_not have_content('{{payment_link}}')
    expect(page).to have_content('{{reference_number}}')

    then_I_should_be_warned_when_leaving_the_page

    when_I_visit_the_reference_payment_page
    with_setting(reference_number_checkbox, false)
    with_setting(payment_link_checkbox, false)
    click_button(I18n.t('actions.save'))
    when_I_visit_the_confirmation_email_settings_page
    when_I_enable_confirmation_email('dev')
    expect(page).to_not have_content('{{reference_number}}')
    expect(page).to_not have_content('{{payment_link}}')
  end

  xscenario 'confirmation page styling updates correctly' do
    with_setting(reference_number_checkbox, true)
    with_setting(payment_link_checkbox, true)
    then_I_should_see_text(payment_link_label)
    with_setting(payment_link_field, valid_url)
    click_button(I18n.t('actions.save'))

    and_I_return_to_flow_page
    given_I_edit_a_confirmation_page(text: I18n.t('presenter.confirmation.payment_enabled'))
    expect(page).to have_css('div.govuk-panel--confirmation-payment', text: confirmation_page_payment_text)

    editor.question_heading.first.set('You have to pay now')
    when_I_save_my_changes
    then_I_should_not_see_text('You still need to pay')
    then_I_should_see_text('You have to pay now')

    editor.question_heading.first.set('Application complete')
    when_I_save_my_changes

    when_I_visit_the_reference_payment_page
    with_setting(payment_link_checkbox, false)
    click_button(I18n.t('actions.save'))
    and_I_return_to_flow_page
    given_I_edit_a_confirmation_page
    expect(page).to have_css('div.govuk-panel--confirmation', text: "Application complete\nYour reference number is:")
    then_I_should_not_see_text('You have to pay now')

    when_I_visit_the_reference_payment_page
    with_setting(payment_link_checkbox, false)
    with_setting(reference_number_checkbox, false)
    click_button(I18n.t('actions.save'))
    and_I_return_to_flow_page
    given_I_edit_a_confirmation_page
    expect(page).to have_css('div.govuk-panel--confirmation', text: "Application complete")
    then_I_should_not_see_text(confirmation_page_payment_text)
  end

  ## Reference Payment Settings Page
  def when_I_visit_the_reference_payment_page
    page.find(:css, '#main-content', visible: true)
    editor.settings_link.click
    expect(page).to have_content(I18n.t('settings.reference_payment.lede'))
    editor.click_link(I18n.t('settings.reference_payment.heading'))
  end

  def then_I_should_see_the_payment_link_settings_configuration
    expect(page).to have_content(I18n.t('settings.reference_payment.heading'))
    expect(page).to have_content(I18n.t('settings.reference_payment.description', href:'user guide (opens in new tab) ' )[0..50], normalize_ws: true, exact: false )
    expect(page).to have_content(I18n.t('settings.reference_number.hint'))
    expect(page).to have_content(I18n.t('settings.payment_link.legend'))
    expect(page).to have_content(I18n.t('settings.payment_link.hint', href:'GOV.UK Pay account')[0..50])
  end

  def with_setting(setting, value)
    page.find(:css, setting, visible: false).set(value)
  end

  def then_checkbox_should_remain_checked(attribute)
    element = find(attribute, visible: false)
    expect(element.checked?).to eq(true)
  end

  ## Pages Flow
  def and_I_edit_the_question
    editor.question_heading.first.set('New Email Component')
  end

  def when_I_update_the_question_name
    and_I_edit_the_question
    when_I_save_my_changes
  end

  ## Confirmation Email Settings Page
  def then_I_add_a_reply_to_email(email, environment)
    editor.find(:css, "input#confirmation-email-settings-confirmation-email-reply-to-#{environment}-field").set(email)
  end
  
  def then_I_should_be_warned_when_leaving_the_page
    accept_confirm(wait: 1) { editor.settings_link.click }
  end
end
