require_relative '../spec_helper'

feature 'Preview form' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:multiple_page_heading) do
    'Multiple Page'
  end
  let(:optional_content) do
    I18n.t('default_text.content')
  end
  let(:content_component) do
    "I am a doctor not a doorstop"
  end
  let(:text_component_question) do
    'What is the name of the Gungan who became a taxi driver?'
  end
  let(:textarea_component_question) do
    'What droid always takes the long way around?'
  end
  let(:content_page_heading) do
    'There is no bathroom'
  end

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'preview the whole form' do
    given_I_add_all_pages_for_a_form
    preview_form = when_I_preview_the_form
    then_I_can_navigate_until_the_end_of_the_form(preview_form)
  end

  scenario 'preview the standalone pages' do
    preview_form = when_I_preview_the_form
    then_I_should_preview_the_cookies_page(preview_form)
    within_window(preview_form) do
      then_I_should_not_see_a_back_link
    end
  end

  def then_I_should_preview_the_cookies_page(preview_form)
    within_window(preview_form) do
      page.find_link('Cookies').click
      expect(page.find('h1').text).to eq('Cookies')
    end
  end

  def given_I_add_all_pages_for_a_form
    given_I_add_a_single_question_page_with_text
    and_I_add_a_page_url('name')
    when_I_add_the_page
    when_I_update_the_question_name('Full name')
    and_I_return_to_flow_page

    given_I_add_a_multiple_question_page
    and_I_add_a_page_url('multi')
    when_I_add_the_page
    and_I_change_the_page_heading(multiple_page_heading)
    and_I_add_the_component(editor.add_text)
    and_I_change_the_text_component(text_component_question)
    when_I_update_the_question_name('Multiple Question page')
    and_I_add_a_multiple_page_content_component(content: content_component)
    and_I_add_the_component(editor.add_text_area)
    and_I_change_the_textarea_component(textarea_component_question, component: 2)
    when_I_save_my_changes
    and_I_return_to_flow_page

    given_I_add_a_content_page
    and_I_add_a_page_url('content-page')
    when_I_add_the_page
    and_I_change_the_page_heading(content_page_heading)
    when_I_save_my_changes
    and_I_return_to_flow_page

    given_I_add_a_single_question_page_with_date
    and_I_add_a_page_url('date-of-birth')
    when_I_add_the_page
    when_I_update_the_question_name('Date of birth')
    and_I_return_to_flow_page

    given_I_add_a_single_question_page_with_checkboxes
    and_I_add_a_page_url('favourite-fruit')
    when_I_add_the_page
    when_I_update_the_question_name('What is your favourite fruit?')
    and_I_edit_the_option_items
    and_I_make_the_question_optional
    and_I_return_to_flow_page

    given_I_add_a_single_question_page_with_upload
    and_I_add_a_page_url('file-upload')
    when_I_add_the_page
    when_I_update_the_question_name('Upload your file')
    and_I_make_the_question_optional
    and_I_return_to_flow_page
  end

  def and_I_add_a_multiple_page_content_component(content:)
    and_I_add_a_component
    and_I_add_a_content_area
    and_the_content_component_has_the_optional_content
    when_I_change_editable_content(editor.second_component, content: content)
  end

  def and_the_content_component_has_the_optional_content
    editor.service_name.click # click outside to close the editable component

    # the output element p tag of a content component is the thing which has
    # the actual text in it
    output_component = editor.second_component.find('.output p', visible: false)
    expect(output_component.text).to eq(optional_content)
  end

  def when_I_update_the_question_name(question_name)
    editor.question_heading.first.set(question_name)
    when_I_save_my_changes
  end

  def then_I_can_navigate_until_the_end_of_the_form(preview_form)
    within_window(preview_form) do
      expect(page.text).to include('Service name goes here')
      then_I_should_not_see_a_back_link
      page.click_button 'Start now'

      expect(page.text).to include('Full name')
      then_I_should_not_see_optional_text
      then_I_should_see_a_back_link
      page.click_button 'Continue'
      then_I_should_see_an_error_message('Full name')
      page.fill_in 'Full name', with: 'Charmy Pappitson'
      page.click_button 'Continue'

      expect(page.text).to include(content_component)
      then_I_should_not_see_optional_text
      then_I_should_see_a_back_link
      page.click_button 'Continue'
      then_I_should_see_an_error_message
      page.fill_in text_component_question, with: 'Car Car Binks'
      page.fill_in textarea_component_question, with: 'R2-Detour'
      page.click_button 'Continue'

      expect(page.text).to include(content_page_heading)
      then_I_should_not_see_optional_text
      then_I_should_see_a_back_link
      page.click_button 'Continue'

      expect(page.text).to include('Date of birth')
      then_I_should_not_see_optional_text
      then_I_should_see_a_back_link
      page.click_button 'Continue'
      then_I_should_see_an_error_message('Date of birth')
      page.fill_in 'Day', with: '03'
      page.fill_in 'Month', with: '06'
      page.fill_in 'Year', with: '2002'
      page.click_button 'Continue'

      expect(page.text).to include('What is your favourite fruit?')
      then_I_should_see_a_back_link
      and_I_select_an_option_item
      page.click_button 'Continue'

      expect(page.text).to include('Upload your file')
      then_I_should_see_a_back_link
      page.click_button 'Continue'

      expect(page.text).to include('Check your answers')
      expect(page.text).to include('Charmy Pappitson')
      expect(page.text).to include('Car Car Binks')
      expect(page.text).to include('R2-Detour')
      expect(page.text).to include('03 June 2002')
      expect(page.text).to include('Apples')
      expect(page.text).to include('Upload your file')
      then_I_should_not_see_optional_text
      then_I_should_see_a_back_link
      then_I_should_not_see_content_page_in_check_your_answers(page)
      then_I_should_not_see_content_components_in_check_your_answers(page)

      and_I_want_to_change_the_checkbox_answer
      expect(page.text).to include('What is your favourite fruit?')
      and_I_unselect_an_option_item
      page.click_button 'Continue'

      expect(page.text).to include('Check your answers')
      expect(page.text).not_to include('Apples')

      page.click_button 'Accept and send application'
      then_I_should_not_see_a_back_link
      expect(page.text).to include('Application complete')
    end
  end

  def then_I_should_not_see_content_page_in_check_your_answers(page)
    expect(page.text).to_not include(content_component)
  end

  def then_I_should_not_see_content_components_in_check_your_answers(page)
    expect(page.text).to_not include(content_page_heading)
  end

  def and_I_edit_the_option_items
    editor.editable_options.first.set('Apples')
    editor.service_name.click
    editor.editable_options.last.set('Oranges')
    editor.service_name.click
    when_I_save_my_changes
  end

  def and_I_make_the_question_optional
    when_I_want_to_select_question_properties
    and_I_want_to_set_a_question_optional
    and_I_update_the_question_to_be_optional
    when_I_save_my_changes
  end

  def and_I_want_to_change_the_checkbox_answer
    page.find(:link, text: 'Your answer for What is your favourite fruit?', visible: false).click
  end

  def and_I_select_an_option_item
    page.find(:css, '#answers-favourite-fruit-checkboxes-1-apples-field', visible: false).check
  end

  def and_I_unselect_an_option_item
    page.find(:css, '#answers-favourite-fruit-checkboxes-1-apples-field', visible: false).uncheck
  end

  def then_I_should_see_a_back_link
    expect(page).to have_selector(:css, 'a[class="govuk-back-link"]')
  end

  def then_I_should_not_see_a_back_link
    expect(page).not_to have_selector(:css, 'a[class="govuk-back-link"]')
  end
end
