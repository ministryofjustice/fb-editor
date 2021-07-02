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
    '[Optional content]'
  end

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'adding and updating components' do
    given_I_have_a_multiple_questions_page
    and_I_add_a_text_component
    and_I_add_a_textarea_component
    and_I_add_a_radio_component
    and_I_add_a_checkbox_component
    and_I_update_the_components
    when_I_save_my_changes
    and_I_return_to_flow_page
    preview_form = and_I_preview_the_form
    then_I_can_answer_the_questions_in_the_page(preview_form)
  end

  scenario 'deleting components' do
    given_I_have_a_multiple_questions_page
    and_I_add_a_text_component
    and_I_add_a_textarea_component
    and_I_change_the_text_component(text_component_question)
    when_I_save_my_changes
    when_I_want_to_select_component_properties('h2', text_component_question)
    and_I_want_to_delete_a_component
    when_I_save_my_changes
    and_the_text_component_is_deleted
  end

  scenario 'deleting content components' do
    given_I_have_a_multiple_questions_page
    then_I_add_a_content_component(
      content: content_component
    )
    when_I_save_my_changes
    then_I_should_see_my_content(content_component)

    when_I_want_to_select_component_properties('.output', content_component)
    and_I_want_to_delete_a_component
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
      page.choose '900 years old', visible: false
      page.check 'Prequels', visible: false
      page.click_button 'Continue'

      # There are no next pages but it means that the continue work and the
      # multiple question is working since filling the form above worked
      # gracefully.
      expect(page.text).to include("The page you were looking for doesn't exist.")
    end
  end

  def and_the_text_component_is_deleted
    expect(page).to have_selector('.Question', count: 1)
  end
end
