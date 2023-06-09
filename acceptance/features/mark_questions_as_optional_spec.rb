require_relative '../spec_helper'

feature 'Mark question as optional' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(fixture: 'default_new_service_fixture')
  end

  scenario 'change required fields to optional' do
    given_I_have_a_single_question_page_with_text
    when_I_mark_the_question_as_optional
    when_I_save_my_changes
    and_I_return_to_flow_page
    given_I_have_a_single_question_page_with_radio
    and_I_return_to_flow_page
    preview_form = when_I_preview_the_form
    then_I_should_pass_the_question_without_answering(preview_form)
  end

  def when_I_mark_the_question_as_optional
    editor.question_heading.first.set('Full name')
    when_I_want_to_select_question_properties
    and_I_want_to_set_a_question_optional
    and_I_update_the_question_to_be_optional
  end

  def page_url
    "Stormtrooper-#{SecureRandom.uuid}"
  end

  def then_I_should_pass_the_question_without_answering(preview_form)
    within_window(preview_form) do
      expect(page).to have_content('Service name goes here')
      page.click_button 'Start now'
      expect(page).to have_content('Full name (optional)')
      page.click_button 'Continue'
      expect(page.text).to_not include('Full name')
      expect(page).to have_content('Option')
    end
  end
end
