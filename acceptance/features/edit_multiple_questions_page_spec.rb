require_relative '../spec_helper'

feature 'Edit multiple questions page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:url) { 'hakuna-matata' }
  let(:page_heading) { 'Star wars questions' }
  let(:text_component_question) do
    'C-3P0 is fluent in how many languages?'
  end
  let(:textarea_component_question) do
    'How Did Maz Kanata End Up With Luke`s Lightsaber?'
  end
  let(:email_component_question) do
    'What is your email address?'
  end
  let(:radio_component_question) do
    'How old is Yoda when he dies?'
  end
  let(:radio_component_options) { ['900 years old'] }
  let(:checkboxes_component_question) do
    'Tell us what are the star wars movies called'
  end
  let(:checkboxes_component_options) do
    ['Prequels']
  end
  let(:content_component) do
    'You underestimate the power of the Dark Side.'
  end
  let(:optional_content) do
    I18n.t('default_text.content')
  end

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'adding and updating components' do
    given_I_have_a_multiple_questions_page
    and_I_add_the_component(editor.add_text)
    and_I_add_the_component(editor.add_text_area)
    and_I_add_the_component(editor.add_email)
    and_I_add_the_component(editor.add_radio)
    and_I_add_the_component(editor.add_checkboxes)
    and_I_update_the_components
    when_I_save_my_changes
    and_I_return_to_flow_page
    preview_form = and_I_preview_the_form
    then_I_can_answer_the_questions_in_the_page(preview_form)
  end

  scenario 'deleting a text component' do
    given_I_have_a_multiple_questions_page
    and_I_add_the_component(editor.add_text)
    and_I_add_the_component(editor.add_text_area)
    and_I_change_the_text_component(text_component_question)
    when_I_save_my_changes
    when_I_want_to_select_component_properties('h2', text_component_question)
    and_I_want_to_delete_a_component(text_component_question)
    when_I_save_my_changes
    and_the_component_is_deleted(1)
  end

  scenario 'deleting an email component' do
    given_I_have_a_multiple_questions_page
    and_I_add_the_component(editor.add_text)
    and_I_add_the_component(editor.add_text_area)
    and_I_add_the_component(editor.add_email)
    and_I_change_the_email_component(email_component_question)
    when_I_save_my_changes
    when_I_want_to_select_component_properties('h2', email_component_question)
    and_I_want_to_delete_a_component(email_component_question)
    when_I_save_my_changes
    and_the_component_is_deleted(2)
  end

  scenario 'deleting content components' do
    given_I_have_a_multiple_questions_page
    then_I_add_a_content_component(
      content: content_component
    )
    when_I_save_my_changes
    then_I_should_see_my_content(content_component)

    when_I_want_to_select_component_properties('.output', content_component)
    and_I_want_to_delete_a_content_component
    when_I_save_my_changes
    then_I_should_not_see_my_content(content_component)
  end

  def then_I_add_a_content_component(content:)
    and_I_add_a_component
    editor.add_content.click
    expect(editor.first_component.text).to eq(optional_content)
    when_I_change_editable_content(editor.first_component, content: content)
  end

  def then_I_can_answer_the_questions_in_the_page(preview_form)
    within_window(preview_form) do
      expect(page.text).to include('Service name goes here')
      page.click_button 'Start now'
      page.fill_in 'C-3P0 is fluent in how many languages?',
        with: 'Fluent in over six million forms of communication.'
      page.fill_in 'How Did Maz Kanata End Up With Luke`s Lightsaber?',
        with: 'Who knows?'
      page.fill_in 'What is your email address?',
        with: 'healthy.harold@justice.gov.uk'
      page.choose '900 years old', visible: false
      page.check 'Prequels', visible: false
      page.click_button 'Continue'
      expect(page.text).to include("Check your answers")
    end
  end

  def and_the_component_is_deleted(components_remaining)
    expect(page).to have_selector('.Question', count: components_remaining)
  end
end
