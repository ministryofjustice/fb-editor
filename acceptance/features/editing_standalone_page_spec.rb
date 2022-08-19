require_relative '../spec_helper'

feature 'Edit standalone pages' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:privacy_heading) { 'Updated privacy heading' }

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(fixture: 'default_new_service_fixture')
  end

  scenario 'the cookies page' do
    given_I_have_footer_pages
    and_I_visit_the_cookies_page
    then_the_page_should_not_be_editable
  end

  scenario 'editing footer standalone pages' do
    given_I_have_footer_pages
    and_I_edit_the_privacy_page
    and_I_change_the_page_heading(privacy_heading)
    when_I_save_my_changes
    then_I_should_see_the_new_privacy_heading
  end

  def given_I_have_footer_pages
    editor.footer_pages_link.click
  end

  def and_I_visit_the_cookies_page
    editor.cookies_link.click
  end

  def then_the_page_should_not_be_editable
    expect { find('.fb-editable') }.to raise_error(Capybara::ElementNotFound)
  end

  def and_I_edit_the_privacy_page
    editor.privacy_link.click
  end

  def then_I_should_see_the_new_privacy_heading
    expect(editor.page_heading.text).to eq(privacy_heading)
  end
end
