# coding: utf-8
require_relative '../spec_helper'

feature 'Publishing' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:page_url) { 'palpatine' }
  let(:exit_url) { 'exit' }
  let(:warning_both) { I18n.t('publish.warning.both_pages') }
  let(:warning_cya) { I18n.t('publish.warning.cya') }
  let(:warning_confirmation) { I18n.t('publish.warning.confirmation') }
  let(:modal_description) { I18n.t('activemodel.attributes.publish_service_creation.description') }
  let(:allow_anyone_text) { I18n.t('publish.dialog.option_1') }
  let(:username_and_password_text) { I18n.t('publish.dialog.option_2') }
  let(:username_and_password_errors) do
    # the use of '‘' is correct
    [
      I18n.t('activemodel.errors.models.publish_service_creation.username_too_short'),
      I18n.t('activemodel.errors.models.publish_service_creation.password_too_short'),
    ]
  end
  let(:publish_to_live_button) { I18n.t('publish.live.button') }
  let(:publish_to_test_button) { I18n.t('publish.test.button') }
  let(:button_class) { '.govuk-button.fb-govuk-button.DialogActivator' }
  let(:test_warning_message) {I18n.t('publish.warning.autocomplete_items', title: 'Question') }
  let(:live_warning_message) { I18n.t('publish.error.autocomplete_items', title: 'Question') }
  let(:upload_button) { I18n.t('dialogs.autocomplete.button') }
  let(:valid_csv_one_column) { './spec/fixtures/autocomplete/valid_one_column.csv' }

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(fixture: 'default_new_service_fixture')
  end

  scenario 'service email output warning message' do
    when_I_visit_the_publishing_page
    then_I_should_see_the_service_output_warning(I18n.t('publish.environment.test'))
    then_I_should_see_the_service_output_warning(I18n.t('publish.environment.live'))

    and_I_click_the_submission_settings_link
    and_I_set_sending_email_for_test_checkbox(true)
    and_I_set_the_email_field
    and_I_save_my_email_settings

    when_I_visit_the_publishing_page
    then_I_should_not_see_the_service_output_warning(I18n.t('publish.environment.test'))
    then_I_should_see_the_service_output_warning(I18n.t('publish.environment.live'))

    and_I_click_the_submission_settings_link
    and_I_set_sending_email_for_test_checkbox(false)
    and_I_save_my_email_settings

    when_I_visit_the_publishing_page
    then_I_should_see_the_service_output_warning(I18n.t('publish.environment.test'))
    then_I_should_see_the_service_output_warning(I18n.t('publish.environment.live'))

    cleanup_service_configuration
  end

  scenario 'when visiting the publishing page with submitting pages present' do
    given_I_have_a_single_question_page_with_upload
    and_I_return_to_flow_page
    when_I_visit_the_publishing_page
    then_I_should_be_on_the_publishing_page
    then_I_should_not_see_warning_both_text
    then_I_should_not_see_warning_cya_text
    then_I_should_not_see_warning_confirmation_text
  end

  scenario 'when visiting the publishing page without submitting pages present' do
    given_I_have_a_single_question_page_with_upload
    and_I_return_to_flow_page
    given_I_add_an_exit_page
    when_I_visit_the_publishing_page
    then_I_should_be_on_the_publishing_page
    then_I_should_see_warning_both_text
    then_I_should_not_see_warning_cya_text
    then_I_should_not_see_warning_confirmation_text
  end

  scenario 'when visiting the publishing page without cya page present' do
    given_I_have_a_single_question_page_with_upload
    and_I_return_to_flow_page
    and_I_delete_cya_page
    then_I_should_see_delete_warning_cya
    when_I_visit_the_publishing_page
    then_I_should_be_on_the_publishing_page
    then_I_should_not_see_warning_both_text
    then_I_should_not_see_warning_confirmation_text
    then_I_should_see_warning_cya_text
  end

  scenario 'when visiting the publishing page without confirmation page present' do
    given_I_have_a_single_question_page_with_upload
    and_I_return_to_flow_page
    when_I_delete_confirmation_page
    when_I_visit_the_publishing_page
    then_I_should_be_on_the_publishing_page
    then_I_should_not_see_warning_both_text
    then_I_should_not_see_warning_cya_text
    then_I_should_see_warning_confirmation_text
  end

  scenario 'when there are autocomplete components with no options' do
    given_I_add_a_single_question_page_with_autocomplete
    and_I_add_a_page_url
    when_I_add_the_page
    and_I_return_to_flow_page
    when_I_visit_the_publishing_page
    then_I_should_be_on_the_publishing_page
    then_I_should_see_autocomplete_warnings
    then_the_aria_attribute_value_should_be_correct(publish_to_live_button, 'true')
  end

  scenario 'when all autocomplete components have options' do
    given_I_add_a_single_question_page_with_autocomplete
    and_I_add_a_page_url
    when_I_add_the_page
    and_I_should_see_default_upload_options_warning
    when_I_click_autocomplete_options_in_three_dots_menu
    then_I_should_see_upload_options_modal
    when_I_upload_a_csv_file(valid_csv_one_column)
    and_I_return_to_flow_page
    when_I_visit_the_publishing_page
    then_I_should_be_on_the_publishing_page
    then_I_should_not_see_autocomplete_warnings
    then_the_aria_attribute_value_should_be_correct(publish_to_live_button, 'false')
  end

  scenario 'when username and password is too short' do
    when_I_visit_the_publishing_page
    then_I_should_be_on_the_publishing_page

    and_I_want_to_publish('Test')
    then_I_should_see_publish_to_test_modal
    then_username_and_password_should_be_the_default('dev')
    when_I_enter_invalid_username_and_password('dev', 'Test', 'dev')
    then_I_should_see_an_error_message('dev', 'Test')

    and_I_cancel

    and_I_want_to_publish('Live')
    then_I_should_not_see_publish_to_test_modal
    then_username_and_password_should_be_selected('production')
    when_I_enter_invalid_username_and_password('live', 'Live', 'production')
    then_I_should_see_an_error_message('live', 'Live')
  end

  def when_I_visit_the_publishing_page
    sleep 0.5 # Allow time for the page to load
    editor.publishing_link.click
  end

  def and_I_want_to_publish(environment)
    page.find('#main-content', visible: true)
    editor.find('#publish-environments').find(:button, text: "Publish to #{environment}").click
  end

  def and_I_click_the_submission_settings_link
    # Test environment submission settings
    editor.all('a', text: I18n.t('publish.service_output.link')).first.click
  end

  def and_I_click_the_send_data_by_email_link
    click_link(I18n.t('settings.submission.email.label'))
  end

  def and_I_set_sending_email_for_test_checkbox(value)
    editor.find(:css, '#email_settings_send_by_email_dev', visible: false).set(value)
  end

  def and_I_set_the_email_field
    editor.find(:css, '#configure-dev').click
    editor.find(:css, '#service_email_output_dev').set('paul@atreides.com')
  end

  def and_I_save_my_email_settings
    click_button(I18n.t('settings.submission.email.save_test'))
  end

  def then_username_and_password_should_be_selected(environment)
    # defaults to requiring a username and password so the radio is pre selected

    # allow anyone
    expect(editor.find("#require_authentication_#{environment}_1", visible: false)).not_to be_checked
    # set username and password
    expect(editor.find("#require_authentication_#{environment}_2", visible: false)).to be_checked
  end

  def then_username_and_password_should_be_the_default(environment)
    # defaults to requiring a username and password so the radio is pre selected

    # allow anyone
    expect(page).to_not have_text(allow_anyone_text)
    # set username and password text
    expect(page).to_not have_text(username_and_password_text)
  end

  def when_I_enter_invalid_username_and_password(environment, button_environment, deployment_environment)
    editor.find("#publish-form-#{environment} #username_#{deployment_environment}").set('foo')
    editor.find("#publish-form-#{environment} #password_#{deployment_environment}").set('bar')
    editor.find('.ui-dialog').find(:button, text: "Publish to #{button_environment}").click
  end

  def then_I_should_see_an_error_message(environment, button_environment)
    page.find(:css, '#main-content', visible: true)
    errors = editor.all("#publish-form-#{environment} .govuk-error-message").map(&:text)
    expect(errors).to match_array(username_and_password_errors)
  end

  def and_I_cancel
    editor.find('.ui-dialog').find(:button, text: 'Cancel').click
  end

  def then_I_should_be_on_the_publishing_page
    expect(editor.question_heading.first.text).to eq(I18n.t('publish.heading'))
    buttons_text = page.all(:css, 'button.fb-govuk-button', visible: false).map(&:text)
    expect(buttons_text).to include(I18n.t('publish.test.button'))
    expect(buttons_text).to include(I18n.t('publish.live.button'))
  end

  def then_I_should_not_see_warning_both_text
    expect(editor.text).to_not include(warning_both)
  end

  def then_I_should_not_see_warning_cya_text
    expect(editor).to_not have_content(warning_cya)
  end

  def then_I_should_not_see_warning_confirmation_text
    expect(editor.text).to_not include(warning_confirmation)
  end

  def then_I_should_see_warning_both_text
    expect(editor).to have_content(warning_both)
  end

  def then_I_should_see_warning_cya_text
    expect(editor).to have_content(warning_cya)
  end

  def then_I_should_see_warning_confirmation_text
    expect(editor).to have_content(warning_confirmation)
  end

  def then_I_should_see_publish_to_test_modal
    expect(editor).to have_content(modal_description)
  end

  def then_I_should_not_see_publish_to_test_modal
    expect(editor).to_not have_content(modal_description)
  end

  def then_I_should_see_the_service_output_warning(deployment_environment)
    warning_message = I18n.t(
      'publish.service_output.message',
      href: I18n.t('publish.service_output.link'),
      environment: deployment_environment
    )
    expect(editor).to have_content(warning_message)
  end

  def then_I_should_not_see_the_service_output_warning(deployment_environment)
    warning_message = I18n.t(
      'publish.service_output.message',
      href: I18n.t('publish.service_output.link'),
      environment: deployment_environment
    )
    expect(editor.text).to_not include(warning_message)
  end

  def cleanup_service_configuration
    # The service config is saved to the DB only using the service id as an identifier.
    # This is just to stop the build up of table rows related to services that
    # will have been deleted by the Metadata API as it cleans up after acceptance
    # test runs.
    and_I_click_the_submission_settings_link
    editor.find(:css, '#configure-dev').click
    editor.find(:css, '#service_email_output_dev').set('')
    and_I_save_my_email_settings
  end

  def then_I_should_see_autocomplete_warnings
    expect(editor.text).to include(test_warning_message)
    expect(editor.text).to include(live_warning_message)
  end

  def then_I_should_not_see_autocomplete_warnings
    expect(editor.text).to_not include(test_warning_message)
    expect(editor.text).to_not include(live_warning_message)
  end

  def then_the_aria_attribute_value_should_be_correct(button, value)
    aria_disabled = page.find(button_class, text: button)['aria-disabled']
    expect(aria_disabled).to eq(value)
  end
end
