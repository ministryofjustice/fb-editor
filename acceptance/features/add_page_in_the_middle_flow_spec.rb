require_relative '../spec_helper'

feature 'Add page in the middle flow' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:start_page) { 'Service name goes here' }
  let(:page_url) { 'palpatine' }
  let(:question) { 'We Both Love Soup And Snow Peas' }
  let(:form_urls) do
    # page url links have the word "Edit" as a visually hidden span element
    # associated with them for added accessibility
    [
      "Service name goes here\n, Start page",
      "We Both Love Soup And Snow Peas\n, Single question page",
      "Question\n, Single question page",
      "Check your answers\n, Check your answers page",
      "Application complete\n, Confirmation page"
    ]
  end

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(fixture: 'default_new_service_fixture')
  end

  scenario 'adding page after first page and before last page' do
    given_I_have_a_single_question_page_with_text
    and_I_return_to_flow_page
    when_I_add_a_single_question_page_with_radio_after_start(url: 'new-page-url')
    when_I_update_the_question_name
    and_I_return_to_flow_page
    then_I_should_see_the_page_flow_in_order(order: form_urls)
  end

  def when_I_add_a_single_question_page_with_radio_after_start(url:)
    editor.connection_menu(start_page).click
    editor.add_single_question.hover
    editor.add_component(I18n.t('components.list.radios')).click
    editor.page_url_field.set(url)
    when_I_add_the_page
    # expect to be on the page created (radio component page)
    expect(editor.radio_options.size).to be(2)
  end

  def when_I_update_the_question_name
    and_I_edit_the_question
    when_I_save_my_changes
  end

  def and_I_edit_the_question
    editor.question_heading.first.set(question)
  end
end
