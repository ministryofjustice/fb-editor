require_relative '../spec_helper'

feature 'Preview page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:page_url) { 'kenobi' }
  let(:url) { 'cya' }

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'preview start page' do
    preview_page = when_I_preview_the_start_page
    then_I_should_preview_the_start_page(preview_page)
  end

  scenario 'preview upload page' do
    given_I_have_a_single_question_page_with_upload
    and_I_return_to_flow_page
    given_I_have_a_check_your_answers_page
    and_I_return_to_flow_page
    preview_page = when_I_preview_the_upload_page
    then_I_should_upload_my_files(preview_page)
  end

  scenario 'preview pages' do
    given_I_have_a_single_question_page_with_text
    and_I_return_to_flow_page
    preview_page = when_I_preview_the_page
    then_I_should_preview_the_page(preview_page)
  end

  def when_I_preview_the_start_page
    editor.preview_page_images.first.hover
    when_I_click_preview_page
  end

  def then_I_should_preview_the_start_page(preview_page)
    within_window(preview_page) do
      expect(page.find('button')).to_not be_disabled
      expect(page.text).to include('Before you start')
      then_I_should_not_see_optional_text
    end
  end

  def then_I_should_upload_my_files(preview_page)
    within_window(preview_page) do
      and_I_upload_my_file
      and_I_change_the_answer_of_my_file
      and_I_go_to_next_page
      then_I_should_be_on_the_check_your_answers_page
      and_I_change_the_answer_of_my_file
      and_I_remove_the_file
      and_I_go_to_next_page
      then_I_should_see_that_I_should_add_a_file
      and_I_upload_my_file
      then_I_should_be_on_the_check_your_answers_page
    end
  end

  def and_I_upload_my_file
    attach_file 'answers[kenobi_upload_1]',
      './acceptance/fixtures/computer_says_no.gif'
    and_I_go_to_next_page
  end

  def and_I_change_the_answer_of_my_file
    click_link 'Change'
  end

  def and_I_go_to_next_page
    click_button 'Continue'
  end

  def then_I_should_be_on_the_check_your_answers_page
    then_I_should_not_see_optional_text
    expect(page.current_url).to include('cya')
  end

  def then_I_should_see_that_I_should_add_a_file
    expect(page.text).to include('There is a problem')
    expect(page.text).to include('Enter an answer for')
  end

  def and_I_remove_the_file
    click_link 'Remove file'
  end

  def when_I_preview_the_upload_page
    editor.preview_page_images[1].hover
    when_I_click_preview_page
  end
end
