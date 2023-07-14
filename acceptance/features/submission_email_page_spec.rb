require_relative '../spec_helper'

feature 'Submission email' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:start_page) { 'Service name goes here' }
  let(:message_body) {
    "Please find attached a submission sent from #{service_name}. Your reference number is: {{reference_number}}."
  }
  let(:message_subject) { "Submission from #{service_name}, reference number: {{reference_number}}" }
  let(:pdf_heading) { "Submission for #{service_name}, reference number: {{reference_number}}" }

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(name: service_name)
  end

  shared_examples 'submission email settings page' do
    scenario 'with valid and invalid send to domains' do
      when_I_visit_the_submission_email_settings_page
      then_I_should_see_the_submission_email_settings_page(environment)
      when_I_enable_submission_email(environment)
      then_I_add_a_send_to_email('iorek.byrnison@outlook.com')
      then_I_should_see_the_error

      then_I_add_a_send_to_email('iorek.byrnison@justice.gov.uk')
      then_I_should_not_see_the_error
    end
  end

  context 'when dev environment' do
    let(:environment) { 'dev' }

    it_behaves_like 'submission email settings page'
  end

  context 'when production environment' do
    let(:environment) { 'production' }

    it_behaves_like 'submission email settings page'
  end

  def when_I_visit_the_submission_email_settings_page
    page.find(:css, '#main-content', visible: true)
    editor.click_link(I18n.t('settings.name'))
    editor.click_link(I18n.t('settings.submission.heading'))
    expect(page).to have_content(I18n.t('settings.collection_email.heading'))
    expect(page).to have_content(I18n.t('settings.collection_email.lede'))
    editor.click_link(I18n.t('settings.collection_email.heading'))
  end

  def then_I_should_see_the_submission_email_settings_page(environment)
    expect(page).to have_content(I18n.t('settings.collection_email.heading'))
    expect(page).to have_content(I18n.t('settings.collection_email.lede'))
    expect(page).to have_content(I18n.t("publish.#{environment}.heading"))
    expect(page).to have_content(I18n.t("publish.#{environment}.description"))
    within( "#email-submission-#{environment}") do
      expect(page).to have_button(I18n.t("actions.saved"))
    end
  end

  def when_I_enable_submission_email(environment)
    page.find(:css, "input#email-settings-send-by-email-#{environment}-1-field", visible: false).set(true)
  end

  def then_I_should_see_submission_email_fields
    expect(page).to have_content(I18n.t('activemodel.attributes.email_settings.service_email_output'))
    expect(page).to have_content(I18n.t('activemodel.attributes.email_settings.service_email_output_hint'))
    expect(page).to have_content(I18n.t('activemodel.attributes.email_settings.service_email_from'))
    expect(page).to have_content(I18n.t('activemodel.attributes.email_settings.service_email_subject'))
    expect(page).to have_content(I18n.t('activemodel.attributes.email_settings.service_email_body'))
    expect(page).to have_content(I18n.t('activemodel.attributes.email_settings.service_email_pdf_heading'))
    expect(page).to have_content(I18n.t('activemodel.attributes.email_settings.service_email_pdf_subheading'))
    expect(page).to have_content(I18n.t('activemodel.attributes.email_settings.pdf_hint'))
    expect(page).to have_content(I18n.t('activemodel.attributes.email_settings.csv_attachment'))
    expect(page).to have_content(service_name)
  end

  def then_I_add_a_send_to_email(email)
    editor.find(:css, "input#email-settings-service-email-output-#{environment}-field").set(email)
    click_button(I18n.t("settings.submission.#{environment}.save_button"))
  end

  def then_I_should_see_the_error
    expect(page).to have_content(I18n.t('activemodel.errors.models.email_settings.domain_invalid'))
  end

  def then_I_should_not_see_the_error
    expect(page).to_not have_content(I18n.t('activemodel.errors.models.email_settings.domain_invalid'))
  end
end
