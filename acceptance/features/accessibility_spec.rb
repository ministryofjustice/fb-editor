require_relative '../spec_helper'
require 'axe-rspec'

feature 'Accessibility' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(fixture: 'all_component_types_fixture')
  end

  scenario 'services list' do
    click_link(I18n.t('partials.header.forms'))
    then_the_page_should_be_accessible

    click_button(I18n.t('services.create'))
    then_the_page_should_be_accessible
  end

  scenario 'flow_view' do
    expect(page).to have_content(I18n.t('pages.flow.heading'))
    page.find(:css, '#main-content', visible: true)
    then_the_page_should_be_accessible

    # Start page modal
    and_I_click_on_the_page_menu('Service name goes here')
    and_I_click_on_use_external_start_page
    then_the_page_should_be_accessible

    click_button('Cancel')
    editor.service_name.click

    # move page modal
    # and_I_click_on_the_page_menu('Text')
    # editor.move_page_link.click
    # then_the_page_should_be_accessible

    # click_button('Cancel')
    # editor.service_name.click

    # delete page modal
    # and_I_click_on_the_page_menu('Text')
    # editor.delete_page_link.click
    # then_the_page_should_be_accessible

    ## With branching

    ## Detatch some pages

  end

  scenario 'settings' do
    click_link(I18n.t('settings.name'))
    then_the_page_should_be_accessible
  end

  scenario 'Settings > Form details' do
    click_link(I18n.t('settings.name'))
    click_link(I18n.t('settings.form_name.heading'))
    then_the_page_should_be_accessible
  end

  scenario 'Settings > Google Analytics' do
    click_link(I18n.t('settings.name'))
    click_link(I18n.t('settings.form_analytics.heading'))
    then_the_page_should_be_accessible

    page.find('#form_analytics_settings_enabled_test', visible: false).check
    page.find('#form_analytics_settings_enabled_live', visible: false).check
    then_the_page_should_be_accessible
  end

  scenario 'Settings > Reference & Payment' do
    click_link(I18n.t('settings.name'))
    click_link(I18n.t('settings.reference_payment.link'))
    then_the_page_should_be_accessible
  end

  scenario 'Settings > Save and Return' do
    click_link(I18n.t('settings.name'))
    click_link(I18n.t('settings.save_and_return.heading'))
    then_the_page_should_be_accessible
  end


  scenario 'Settings > Submission Settings Index' do
    click_link(I18n.t('settings.name'))
    click_link(I18n.t('settings.submission.heading'))
    then_the_page_should_be_accessible
  end

  scenario 'Submission Settings > Collect information' do
    click_link(I18n.t('settings.name'))
    click_link(I18n.t('settings.submission.heading'))
    click_link(I18n.t('settings.collection_email.heading'))
    then_the_page_should_be_accessible

    page.find('#email-settings-send-by-email-dev-1-field', visible: false).check
    page.find('#email-settings-send-by-email-production-1-field', visible: false).check
    then_the_page_should_be_accessible
  end

  scenario 'Submission Settings > Send a confirmation email' do
    given_I_add_a_single_question_page_with_email
    and_I_add_a_page_url('email-page')
    when_I_add_the_page

    click_link(I18n.t('settings.name'))
    click_link(I18n.t('settings.submission.heading'))
    click_link(I18n.t('settings.confirmation_email.heading'))
    then_the_page_should_be_accessible

    page.find('#confirmation-email-settings-send-by-confirmation-email-dev-1-field', visible: false).check
    page.find('#confirmation-email-settings-send-by-confirmation-email-production-1-field', visible: false).check
    then_the_page_should_be_accessible
  end

  scenario 'Publishing' do
    # Publishing to Test
    click_link(I18n.t('publish.name'))
    then_the_page_should_be_accessible

    click_button(I18n.t('actions.publish_to_test'))
    then_the_page_should_be_accessible

    click_button('Cancel')

    # Publishing to Live
    first(:link, I18n.t('actions.publish_to_live')).click
    then_the_page_should_be_accessible

    click_button(I18n.t('actions.publish_to_live'))
    then_the_page_should_be_accessible
  end

  context 'Standalone Pages' do
    scenario 'Privacy Page', pending: true do
      editor.privacy_link.click
      then_the_page_should_be_accessible
    end

    scenario 'Cookies Page' do
      editor.cookies_link.click
      then_the_page_should_be_accessible
    end

    scenario 'Accessibility Page', pending: true do
      editor.accessibility_link.click
      then_the_page_should_be_accessible
    end
  end

  context 'Editing Pages' do
      let(:exit_url) { 'Exit Page' }
    
    scenario 'Confirmation Page' do
      given_I_edit_a_confirmation_page
      then_the_page_should_be_accessible
    end

    scenario 'Check Answers Page' do
      given_I_edit_a_check_your_answers_page
      then_the_page_should_be_accessible
    end

    scenario 'Start Page' do
      click_link('Service name goes here')
      then_the_page_should_be_accessible
    end

    scenario 'Content Page' do
      and_I_add_a_content_page('Some Content')
      then_the_page_should_be_accessible
    end

    scenario 'Exit Page' do
      given_I_add_an_exit_page
      then_the_page_should_be_accessible
    end

    scenario 'Multiple Question Page', pending: true do
      given_I_have_a_multiple_questions_page
      then_the_page_should_be_accessible
    end

    context 'Single Question Pages' do
      scenario 'Text Question' do
        # given_I_have_a_single_question_page_with_text
        click_link('Text')
        then_the_page_should_be_accessible
      end

      scenario 'Textarea Question' do
        click_link('Textarea')
        then_the_page_should_be_accessible
      end

      scenario 'Email Question' do
        click_link('Email address question')
        then_the_page_should_be_accessible
      end

      scenario 'Number Question' do
        click_link('Number')
        then_the_page_should_be_accessible
      end

      scenario 'Date Question' do
        click_link('Date')
        then_the_page_should_be_accessible
      end

      scenario 'Radios Question', pending: true do
        click_link('Radios')
        then_the_page_should_be_accessible
      end

      scenario 'Checkboxes Question', pending: true do
        click_link('Checkboxes')
        then_the_page_should_be_accessible
      end

      scenario 'File Upload Question' do
        click_link('Multifile upload')
        then_the_page_should_be_accessible
      end

      scenario 'Autocomplete Question' do
        given_I_want_to_add_a_single_question_page
        editor.add_component(I18n.t('components.list.autocomplete')).click
        and_I_add_a_page_url('autocomplete')
        when_I_add_the_page
        then_the_page_should_be_accessible
      end

      scenario 'Address Question' do
        given_I_want_to_add_a_single_question_page
        editor.add_component(I18n.t('components.list.address')).click
        and_I_add_a_page_url('address')
        when_I_add_the_page
        then_the_page_should_be_accessible
      end
    end

    scenario 'Adding a Branching Point', pending: true do
        editor.connection_menu('Checkboxes Question').click
        and_I_add_branching_to_the_page
        then_the_page_should_be_accessible
        
      ### Interact with the page and check
    end

    scenario 'Editing a Branching Point' do
      # then_the_page_should_be_accessible
    end

  end

  def then_the_page_should_be_accessible
    expect(page).to be_axe_clean.according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa, :wcag22aa, :'best-practice')
  end


  def and_I_click_on_use_external_start_page
    page.click_on I18n.t('actions.enable_external_start_page')
  end
end
