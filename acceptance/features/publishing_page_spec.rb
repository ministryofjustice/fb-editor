# coding: utf-8
require_relative '../spec_helper'

feature 'Publishing' do
  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(fixture: 'default_new_service_fixture')
  end
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:page_url) { 'palpatine' }
  let(:modal_description) { I18n.t('activemodel.attributes.publish_service_creation.description') }
  let(:allow_anyone_text) { I18n.t('publish.dialog.option_1') }
  let(:username_and_password_text) { I18n.t('publish.dialog.option_2') }
  let(:username_and_password_errors) do
    [
      I18n.t('activemodel.errors.models.publish_service_creation.username_too_short'),
      I18n.t('activemodel.errors.models.publish_service_creation.password_too_short'),
    ]
  end

  shared_examples 'a publishing page environment' do
    let(:exit_url) { 'exit' }

    let(:button_class) { '.govuk-button.fb-govuk-button.DialogActivator' }
    let(:autocomplete_warning_message) { I18n.t("publish.autocomplete_items.#{environment}.message", title: 'Question') }
    let(:upload_button) { I18n.t('dialogs.autocomplete.button') }
    let(:valid_csv_one_column) { './spec/fixtures/autocomplete/valid_one_column.csv' }

    scenario 'service email output warning message and submission pages present' do
      when_I_visit_the_publishing_page

      then_I_should_see_the_no_service_output_message
      then_the_publish_button_should_be_enabled
      then_I_click_the_collecting_information_by_email_link
      then_I_should_be_on_collecting_information_by_email_page
      when_I_enable_the_submission_settings

      when_I_visit_the_publishing_page
      then_I_should_see_the_submission_warning_message
      then_I_should_not_see_warning_both_text
      then_I_should_not_see_warning_cya_text
      then_I_should_not_see_warning_confirmation_text
    end

    scenario 'when visiting the publishing page without submitting pages present' do
      given_I_have_a_single_question_page_with_upload
      and_I_return_to_flow_page
      and_I_delete_cya_page
      then_I_should_see_delete_warning_cya

      when_I_enable_the_submission_settings
      when_I_visit_the_publishing_page
      then_I_should_see_the_submission_warning_message
      then_I_should_not_see_warning_both_text
      then_I_should_not_see_warning_confirmation_text
      then_I_should_see_warning_cya_text

      and_I_return_to_flow_page
      given_I_add_an_exit_page
      when_I_visit_the_publishing_page
      then_I_should_see_the_submission_warning_message
      then_I_should_see_warning_both_text
      then_I_should_not_see_warning_cya_text
      then_I_should_not_see_warning_confirmation_text
    end

    scenario 'when visiting the publishing page without confirmation page present' do
      given_I_have_a_single_question_page_with_upload
      and_I_return_to_flow_page
      when_I_delete_confirmation_page

      when_I_enable_the_submission_settings
      when_I_visit_the_publishing_page
      then_I_should_not_see_warning_both_text
      then_I_should_not_see_warning_cya_text
      then_I_should_see_warning_confirmation_text
    end

    scenario 'autocomplete item warning messages' do
      given_I_add_a_single_question_page_with_autocomplete
      and_I_add_a_page_url
      when_I_add_the_page
      and_I_return_to_flow_page

      when_I_enable_the_submission_settings
      when_I_visit_the_publishing_page
      then_I_should_see_the_submission_warning_message
      then_I_should_see_autocomplete_warnings
      then_I_should_see_the_publish_button

      and_I_return_to_flow_page
      and_I_edit_the_page(url: 'Question')
      when_I_click_autocomplete_options_in_three_dots_menu
      then_I_should_see_upload_options_modal
      when_I_upload_a_csv_file(valid_csv_one_column)

      when_I_visit_the_publishing_page
      then_I_should_not_see_autocomplete_warnings
      then_I_should_see_the_publish_button
    end

    scenario 'when from address is not validated' do
      when_I_enable_the_submission_settings
      when_I_visit_the_publishing_page
      then_I_should_see_from_address_warning('default')

      when_I_visit_the_from_address_settings_page
      when_I_change_my_from_address('miriel@numenor.me')

      when_I_visit_the_publishing_page
      then_I_should_see_from_address_warning('pending')
    end
  end

  context 'when dev environment' do
    let(:environment) { 'dev' }
    let(:publish_button) { I18n.t('publish.dev.button') }
    let(:button_disabled) { '' } # aria-disabled is not set when button is enabled
    let(:warning_both){ 'it is missing a check answers page and confirmation page' }
    let(:warning_cya){ 'it is missing a check answers page' }
    let(:warning_confirmation){ 'it is missing a confirmation page'}

    it_behaves_like 'a publishing page environment'
  end

  context 'when production environment' do
    let(:environment) { 'production' }
    let(:publish_button) { I18n.t('publish.production.button') }
    let(:button_disabled) { 'true' }
    let(:warning_both){ 'add a check answers page and confirmation page' }
    let(:warning_cya){ 'add a check answers page' }
    let(:warning_confirmation){ 'add a confirmation page'}

    it_behaves_like 'a publishing page environment'
  end

  scenario 'when username and password is too short' do
    # We are unable to test the Production environment as we cannot
    # validate the 'from' address email, which in turn blocks a user
    # from clicking the 'Publish to Live' button
    when_I_visit_the_publishing_page
    and_I_want_to_publish('Test')
    then_I_should_see_publish_to_test_modal

    then_username_and_password_should_be_the_default('dev')
    when_I_enter_invalid_username_and_password('dev', 'Test')
    then_I_should_see_an_error_message('dev', 'Test')

    and_I_cancel
  end

  def then_I_should_see_the_no_service_output_message
    message = environment_section.find(:css, '.govuk-warning-text__text').text
    expect(message).to include(I18n.t('publish.service_output.message', href_collection_information_by_email: I18n.t('publish.service_output.link') ))
  end

  def then_I_click_the_collecting_information_by_email_link
    environment_section.find(:css,'.govuk-link').click
  end

  def then_I_should_be_on_collecting_information_by_email_page
    expect(page).to have_content(I18n.t('settings.collection_email.heading'))
  end

  def then_I_should_see_the_publish_button
    expect(environment_section.find(:css, 'button')[:'aria-disabled']).to eq(button_disabled)
  end

  def then_the_publish_button_should_be_enabled
    expect(environment_section.find(:css, 'button')[:'aria-disabled']).to eq('false').or eq('')
  end

  def environment_section
    page.find(:css, "section.publish-environment--#{environment}")
  end

  def when_I_visit_the_publishing_page
    sleep 0.5 # Allow time for the page to load
    editor.publishing_link.click
  end

  def and_I_want_to_publish(button_environment)
    page.find('#main-content', visible: true)
    editor.find('#publish-environments').find(:button, text: "Publish to #{button_environment.capitalize}").click
  end

  def when_I_enable_the_submission_settings
    and_I_visit_the_submission_settings_page
    and_I_set_send_by_email(true)
    and_I_set_the_email_field
    and_I_save_my_email_settings
  end

  def and_I_set_the_email_field(value = 'paul@atreides.com')
    editor.find(:css, "#email-settings-service-email-output-#{environment}-field").set(value)
  end

  def and_I_save_my_email_settings
    click_button(I18n.t("settings.submission.#{environment}.save_button"))
  end

  def then_I_should_see_username_and_password_fields
    # defaults to requiring a username and password
    editor.find(:css, "input#username_#{environment}")
    editor.find(:css, "input#password_#{environment}")
  end

  def then_username_and_password_should_be_the_default(environment)
    # defaults to requiring a username and password so the radio is pre selected

    # allow anyone
    expect(page).to_not have_text(allow_anyone_text)
    # set username and password text
    expect(page).to_not have_text(username_and_password_text)
  end

  def when_I_enter_invalid_username_and_password(environment, button_environment)
    editor.find("#username_#{environment}").set('foo')
    editor.find("#password_#{environment}").set('bar')
    editor.find('.ui-dialog').find(:button, text: "Publish to #{button_environment.capitalize}").click
  end

  def then_I_should_see_an_error_message(environment, button_environment)
    page.find(:css, '#main-content', visible: true)
    errors = editor.all("form#publish-form-#{environment} .govuk-error-message").map(&:text)
    expect(errors).to match_array(username_and_password_errors)
  end

  def and_I_cancel
    editor.find('.ui-dialog').find(:button, text: 'Cancel').click
  end

  def then_I_should_not_see_warning_both_text
    expect(environment_section.text).to_not include(warning_both)
  end

  def then_I_should_not_see_warning_cya_text
    expect(environment_section).to_not have_content(exact_text: warning_cya)
  end

  def then_I_should_not_see_warning_confirmation_text
    expect(environment_section.text).to_not include(warning_confirmation)
  end

  def then_I_should_see_warning_both_text
    expect(environment_section.text).to have_content(warning_both)
  end

  def then_I_should_see_warning_cya_text
    expect(environment_section.text).to have_content(warning_cya)
  end

  def then_I_should_see_warning_confirmation_text
    expect(environment_section.text).to have_content(warning_confirmation)
  end

  def then_I_should_see_publish_to_test_modal
    expect(editor).to have_content(modal_description)
  end

  def then_I_should_see_the_submission_warning_message
    expect(editor.text).to include(I18n.t("warnings.publish.#{environment}.heading"))
  end

  def then_I_should_see_from_address_warning(status)
    expect(editor.text).to include(I18n.t("warnings.from_address.publishing.#{environment}.#{status}", href: I18n.t("warnings.from_address.publishing.link")))
  end

  def then_I_should_see_autocomplete_warnings
    expect(environment_section.text).to include(autocomplete_warning_message)
  end

  def then_I_should_not_see_autocomplete_warnings
    expect(environment_section.text).to_not include(autocomplete_warning_message)
  end
end
