require_relative '../spec_helper'

feature 'Confirmation email' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:start_page) { 'Service name goes here' }
  let(:question) { 'New Email Component' }
  # Capybara strips out the carriage return `\r`
  let(:message_body) {
    "Thank you for your submission to ‘#{service_name}’. \n\nA copy of the information you provided is attached to this email."
    I18n.t('default_values.confiramtion_email_body', service_name: service_name).gsub!('{{refernce_number_placeholder}}','')
  }
  let(:message_subject) { "Your submission to ‘#{service_name}’" }
  let(:multiple_question_page) { 'Title' }
  let(:email_question) { 'Email address question' }
  let(:text_component_question) { 'Question' }
  let(:invalid_format) { I18n.t('activemodel.errors.models.from_address.invalid') }
  let(:invalid_domain) { I18n.t('activemodel.errors.models.reply_to.domain_invalid') }

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(name: service_name)
  end

  scenario 'confirmation email settings page without email components' do
    when_I_visit_the_confirmation_email_settings_page
    then_I_should_see_the_confirmation_email_warning_page
  end

  scenario 'deleting a page with email component used for confirmation email' do
    then_I_add_a_page_with_email_component
    when_I_visit_the_confirmation_email_settings_page
    when_I_enable_confirmation_email('dev')
    then_I_fill_in_reply_to_email('valid_email@justice.gov.uk', 'dev')
    click_button(I18n.t('settings.submission.dev.save_button'))

    and_I_return_to_flow_page
    and_I_click_to_delete_email_component(question)
    then_I_should_see_a_delete_page_modal
    click_button(I18n.t('pages.cancel'))

    when_I_visit_the_confirmation_email_settings_page
    when_I_disable_confirmation_email('dev')
    click_button(I18n.t('settings.submission.dev.save_button'))
    and_I_return_to_flow_page
    and_I_click_to_delete_email_component(question)
    then_I_should_see_the_default_delete_modal
  end

  scenario 'deleting an email component on multiple question page' do
    then_I_add_a_multiple_question_page
    and_I_add_the_component(I18n.t('components.list.email'))

    when_I_visit_the_confirmation_email_settings_page
    when_I_enable_confirmation_email('dev')
    then_I_fill_in_reply_to_email('valid_email@justice.gov.uk', 'dev')
    click_button(I18n.t('settings.submission.dev.save_button'))

    and_I_return_to_flow_page
    and_I_click_to_delete_email_component(multiple_question_page)
    then_I_should_see_a_delete_page_modal
    click_button(I18n.t('pages.cancel'))

    and_I_edit_the_page(url: multiple_question_page)
    and_I_add_the_component(I18n.t('components.list.text'))

    when_I_want_to_select_component_properties('h2', email_question)
    and_I_click_the_delete_link
    then_I_should_see_a_delete_question_modal
    click_button(I18n.t('pages.cancel'))

    when_I_visit_the_confirmation_email_settings_page
    when_I_disable_confirmation_email('dev')
    click_button(I18n.t('settings.submission.dev.save_button'))

    and_I_return_to_flow_page
    and_I_edit_the_page(url: multiple_question_page)
    when_I_want_to_select_component_properties('h2', email_question)
    and_I_click_the_delete_link
    then_I_should_see_the_default_delete_modal
    click_button(I18n.t('pages.cancel'))

    when_I_want_to_select_component_properties('h2', text_component_question)
    and_I_want_to_delete_a_component(text_component_question)
    when_I_save_my_changes
    and_the_component_is_deleted(text_component_question, remaining: 1)
  end

  shared_examples 'confirmation email settings page' do
    scenario 'with email validations' do
      then_I_add_a_page_with_email_component
      when_I_visit_the_confirmation_email_settings_page
      then_I_should_see_the_confirmation_email_settings_page(environment)
      when_I_enable_confirmation_email(environment)
      then_I_should_see_confirmation_email_fields
      then_I_should_see_the_confirmation_email_defaults
      then_I_should_see_email_component_question_selected
      then_I_add_a_reply_to_email('email no formatty')
      click_button(I18n.t("settings.submission.#{environment}.save_button"))
      then_I_should_see_the_error(invalid_format)

      when_I_disable_confirmation_email(environment)
      when_I_enable_confirmation_email(environment)
      then_I_add_a_reply_to_email('iorek.byrnison@outlook.com', "-error")
      click_button(I18n.t("settings.submission.#{environment}.save_button"))
      then_I_should_see_the_error(invalid_domain)

      when_I_disable_confirmation_email(environment)
      when_I_enable_confirmation_email(environment)
      then_I_add_a_reply_to_email('iorek.byrnison@digital.justice.gov.uk', "-error")
      click_button(I18n.t("settings.submission.#{environment}.save_button"))
      then_I_should_see_no_error_message
    end
  end

  context 'when dev environment' do
    let(:environment) { 'dev' }

    it_behaves_like 'confirmation email settings page'
  end

  context 'when production environment' do
    let(:environment) { 'production' }

    it_behaves_like 'confirmation email settings page'
  end

  ## Confirmation Email Settings page
  def then_I_should_see_the_confirmation_email_settings_page(environment)
    expect(page).to have_content(I18n.t('settings.confirmation_email.heading'))
    expect(page).to have_content(I18n.t('settings.confirmation_email.description'))
    expect(page).to have_content(I18n.t("activemodel.attributes.confirmation_email_settings.send_by_confirmation_email_#{environment}"))
    expect(page).to have_content(I18n.t("publish.#{environment}.description"))
    expect(page).to have_button(I18n.t("actions.saved"))
  end

  def when_I_disable_confirmation_email(environment)
    page.find(:css, "input#confirmation-email-settings-send-by-confirmation-email-#{environment}-1-field", visible: false).set(false)
  end

  def then_I_should_see_the_confirmation_email_warning_page
    expect(page).to have_content(
      I18n.t('warnings.confirmation_email.message',
      href:  I18n.t('warnings.confirmation_email.link_text')
      )
    )
  end

  def then_I_should_see_the_error(error)
    expect(page).to have_content(error)
  end

  def then_I_should_see_confirmation_email_fields
    expect(page).to have_content(I18n.t('activemodel.attributes.confirmation_email_settings.confirmation_email_component_id'))
    expect(page).to have_content(I18n.t('activemodel.attributes.confirmation_email_settings.confirmation_email_subject'))
    expect(page).to have_content(I18n.t('activemodel.attributes.confirmation_email_settings.confirmation_email_body'))
    expect(page).to have_content(I18n.t('activemodel.attributes.confirmation_email_settings.send_by_confirmation_email_dev'))
    expect(page).to have_content(I18n.t('activemodel.attributes.confirmation_email_settings.send_by_confirmation_email_production'))
    expect(page).to have_content(I18n.t('activemodel.attributes.email_settings.pdf_hint'))
    expect(page).to have_content(I18n.t('activemodel.attributes.email_settings.pdf_sample'))
    expect(page).to have_content(service_name)
  end

  def then_I_should_see_the_confirmation_email_defaults
    expect(page).to have_content(service_name)
    expect(page).to have_content(I18n.t('activemodel.attributes.email_settings.reply_to'))
    expect(page.find(:css, "input#confirmation-email-settings-confirmation-email-subject-#{environment}-field").value).to have_content(message_subject)
    expect(page).to have_content(message_body)
  end

  def then_I_add_a_reply_to_email(email, error="")
    input = editor.find(:css, "input#confirmation-email-settings-confirmation-email-reply-to-#{environment}-field#{error}")
    input.fill_in(with: email)
    # click_button(I18n.t("settings.submission.#{environment}.save_button"))
  end

  def then_I_should_see_email_component_question_selected
    expect(page).to have_select('confirmation_email_settings[confirmation_email_component_id]', selected: question)
  end

  ## Add an email component
  def then_I_add_a_page_with_email_component
    and_I_return_to_flow_page
    when_I_add_a_single_question_page_with_email_after_start(url: 'new-email')
    when_I_update_the_question_name
    and_I_return_to_flow_page
  end

  def then_I_add_a_multiple_question_page
    and_I_return_to_flow_page
    editor.connection_menu(start_page).click
    editor.add_multiple_question.click
    and_I_add_a_page_url(question)
    when_I_add_the_page
  end

  def when_I_update_the_question_name
    and_I_edit_the_question
    when_I_save_my_changes
  end

  def and_I_edit_the_question
    editor.question_heading.first.set(question)
  end

  ## Delete an email component
  def and_I_click_to_delete_email_component(question)
    page.find('.flow-thumbnail', text: question).hover
    and_I_click_on_the_three_dots
    editor.delete_page_link.click
  end

  def then_I_should_see_no_error_message
    page.find(:css, '#main-content', visible: true)
    expect(page).to_not have_content(I18n.t('activemodel.errors.summary_title'))
  end

  def and_the_component_is_deleted(question, remaining:)
    expect(page).to_not have_selector('h2', text: question)
    expect(page).to have_selector('.Question', count: remaining)
  end

## Delete modals
  def then_I_should_see_a_delete_page_modal
    expect(page).to have_content(
      I18n.t('pages.delete_modal.can_not_delete_email_page_message')
    )
  end

  def then_I_should_see_a_delete_question_modal
    expect(page).to have_content(
      I18n.t('questions.delete_modal.can_not_delete_message_confirmation_email')
    )
  end

  def then_I_should_see_the_default_delete_modal
    expect(page).to have_content(I18n.t('dialogs.message_delete'))
  end
end
