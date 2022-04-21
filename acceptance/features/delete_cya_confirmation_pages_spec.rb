
require_relative '../spec_helper'

feature 'Delete cya confirmation pages' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:page_url) { 'gateau' }
  let(:exit_url) { 'exit' }

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(fixture: 'default_new_service_fixture')
  end

  scenario 'when deleting CYA page' do
    then_I_should_see_default_service_pages
    then_I_should_not_see_delete_warnings
    and_I_delete_cya_page
    then_I_should_see_delete_warning_cya
  end

  scenario 'when deleting Confirmation page' do
    then_I_should_see_default_service_pages
    then_I_should_not_see_delete_warnings
    when_I_delete_confirmation_page
    then_I_should_see_delete_warning_confirmation
  end

  scenario 'when deleting both CYA and Confirmation pages' do
    then_I_should_see_default_service_pages
    then_I_should_not_see_delete_warnings
    when_I_delete_confirmation_page
    and_I_delete_cya_page
    then_I_should_see_delete_warning_both
  end

  scenario 'when both CYA and Confirmation pages are disconnected' do
    then_I_should_see_default_service_pages
    then_I_should_not_see_delete_warnings
    given_I_have_a_single_question_page_with_upload
    and_I_return_to_flow_page
    given_I_add_an_exit_page
    and_I_return_to_flow_page
    then_I_should_see_delete_warning_both
  end
end
