
require_relative '../spec_helper'

feature 'Edit single radios question page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:page_url) { 'star-wars-question' }
  let(:question) do
    'Which program do Jedi use to open PDF files?'
  end
  let(:initial_options) do
    ['Adobe-wan Kenobi', 'PDFinn']
  end
  let(:options_after_addition) do
    ['Adobe-wan Kenobi', 'PDFinn', 'Jar Jar Binks']
  end
  let(:options_after_deletion) do
    ['Adobe-wan Kenobi', 'PDFinn']
  end
  let(:section_heading) { 'I open at the close' }
  let(:default_section_heading) { I18n.t('default_text.section_heading') }

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'when editing the checkbox component' do
    given_I_have_a_single_question_page_with_checkboxes
    and_I_have_optional_section_heading_text
    when_I_update_the_question_name
    and_I_update_the_options
    when_I_update_the_optional_section_heading
    when_I_delete_the_optional_section_heading_text
    and_I_return_to_flow_page
    preview_form = then_I_should_see_my_changes_on_preview
    and_I_should_see_the_options_that_I_added(preview_form, initial_options)
  end

  scenario 'when adding an option to the checkbox component' do
    given_I_have_a_single_question_page_with_checkboxes
    when_I_update_the_question_name
    and_I_update_the_options
    and_I_add_an_option('Jar Jar Binks')
    then_I_should_see_the_options(options_after_addition)
    and_I_return_to_flow_page
    preview_form = then_I_should_see_my_changes_on_preview
    and_I_should_see_the_options_that_I_added(preview_form, options_after_addition)
  end

  scenario 'when deleting an option from the checkbox component' do
    given_I_have_a_single_question_page_with_checkboxes
    when_I_update_the_question_name
    and_I_update_the_options
    and_I_add_an_option('Jar Jar Binks')
    then_I_should_see_the_options(options_after_addition)
    and_I_delete_an_option('Jar Jar Binks')
    then_I_should_see_the_options(options_after_deletion)
    and_I_return_to_flow_page
    preview_form = then_I_should_see_my_changes_on_preview
    and_I_should_see_the_options_that_I_added(preview_form, options_after_deletion)
  end

  def given_I_have_a_single_question_page_with_checkboxes
    given_I_add_a_single_question_page_with_checkboxes
    and_I_add_a_page_url
    when_I_add_the_page
  end

  def when_I_update_the_optional_section_heading
    and_I_edit_the_optional_section_heading
    when_I_save_my_changes
    then_I_should_see_my_updated_section_heading
  end

  def when_I_delete_the_optional_section_heading_text
    editor.section_heading_hint.set(' ')
    when_I_save_my_changes
    then_I_should_see_the_default_section_heading
  end

  def when_I_update_the_question_name
    and_I_edit_the_question
    when_I_save_my_changes
  end
  
  def and_I_edit_the_question
    editor.question_heading.first.set(question)
  end

  def and_I_edit_the_optional_section_heading
    page.first('.fb-section_heading').set(section_heading)
  end

  def and_I_update_the_options
    and_I_edit_the_options
    when_I_save_my_changes
  end

  def and_I_edit_the_options
    editor.editable_options.first.set(initial_options.first)
    editor.editable_options.last.set(initial_options.last)
  end

  def and_I_add_an_option(option_label)
    click_button(I18n.t('actions.option_add'))
    page.find('label', text: I18n.t('default_text.option')).base.send_keys(option_label)
    when_I_save_my_changes
  end

  def and_I_delete_an_option(option_label)
    when_I_want_to_select_component_properties('label', option_label)
    click_button(I18n.t('question.menu.remove'))
    expect(page).to have_selector('.DialogConfirmation')
    click_button(I18n.t('dialogs.button_delete_option'))
    expect(page).to_not have_text(option_label)
  end

  def and_I_have_optional_section_heading_text
    expect(page.text).to include(I18n.t('default_text.section_heading'))
  end

  def and_I_go_to_the_page_that_I_edit(preview_form)
    within_window(preview_form) do
      page.click_button 'Start now'
    end
  end

  def then_I_should_see_my_updated_section_heading
    expect(editor.text).to include(section_heading)
  end

  def then_I_should_see_the_default_section_heading
    expect(editor.section_heading_hint.text).to eq(default_section_heading)
  end

  def then_I_should_see_the_options(options)
    expect(editor.checkboxes_options.size).to eql options.size
    options.each do |option|
      expect(page.text).to include(option)
    end
  end

  def then_I_should_see_my_changes_on_preview
    preview_form = and_I_preview_the_form

    and_I_go_to_the_page_that_I_edit(preview_form)
    then_I_should_see_my_changes_in_the_form(preview_form)
    then_I_should_not_see_optional_text

    preview_form
  end

  def then_I_should_see_my_changes_in_the_form(preview_form)
    within_window(preview_form) do
      expect(page.text).to include(question)
    end
  end

  def and_I_should_see_the_options_that_I_added(preview_form, options)
    within_window(preview_form) do
      options.each do |option|
        expect(page.text).to include(option)
      end
    end
  end
end
