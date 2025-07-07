# require_relative '../spec_helper'

# feature 'Deleting page' do
#   let(:editor) { EditorApp.new }
#   let(:service_name) { generate_service_name }
#   let(:exit_url) { 'exit' }
#   let(:exit_page_title) { 'Exit page' }
#   let(:page_url) { 'dooku' }
#   let(:question_title) { 'Question' }

#   background do
#     given_I_am_logged_in
#     given_I_have_a_service_fixture(fixture: 'two_branching_points_fixture')
#   end

#   scenario 'when deleting other pages' do
#     given_I_have_a_single_question_page_with_text
#     and_I_return_to_flow_page
#     and_I_want_to_delete_the_page_that_I_created
#     when_I_delete_the_page
#     then_I_should_not_see_the_deleted_page_anymore
#   end

#   scenario 'when try to delete a page which has a branching conditional' do
#     when_I_try_to_delete_a_page_which_has_a_branching_conditional
#     then_I_should_see_a_message_that_is_not_possible_to_delete_the_page
#   end

#   scenario 'when try to delete a page which result with a stack branch' do
#     when_I_try_to_delete_a_page_which_result_in_a_stack_branch
#     then_I_should_see_a_message_that_is_not_possible_to_create_stack_branches
#   end

#   scenario 'when deleting a branch destination with a default next' do
#     and_I_want_to_delete_a_branch_destination_page
#     when_I_delete_the_branch_destination_page
#     then_I_should_not_see_the_deleted_page_in_the_flow
#     and_I_should_see_the_new_destination_as_next_page_after_the_deleted_page
#   end

#   scenario 'when deleting a branch destination with no default next' do
#     given_I_add_an_exit_page
#     and_I_update_the_exit_page_question
#     and_I_return_to_flow_page
#     given_I_set_the_exit_page_as_a_branch_destination
#     and_I_return_to_flow_page
#     try_to_delete_page(exit_page_title)
#     then_I_should_see_the_delete_page_no_default_next_modal
#   end

#   scenario 'when deleting a branch' do
#     and_I_click_to_delete_branching_point_one
#     and_I_choose_page_c_to_connect_the_forms
#     when_I_delete_the_branching_point
#     then_I_should_see_branch_pointing_one_deleted
#   end

#   def when_I_try_to_delete_a_page_which_has_a_branching_conditional
#     try_to_delete_page('Page b')
#   end

#   def when_I_try_to_delete_a_page_which_result_in_a_stack_branch
#     try_to_delete_page('Page g')
#   end

#   def and_I_click_to_delete_branching_point_one
#     editor.hover_branch('Branching point 1')
#     and_I_click_on_the_three_dots
#     editor.delete_branch_link.click
#   end

#   def and_I_choose_page_c_to_connect_the_forms
#     choose 'Page c', visible: false
#   end

#   def when_I_delete_the_branching_point
#     editor.delete_branching_point_button.click
#   end

#   def then_I_should_see_branch_pointing_one_deleted
#     expect(page).to_not have_content('Branching point 1')
#   end

#   def then_I_should_see_a_message_that_is_not_possible_to_delete_the_page
#     expect(page).to have_content(
#       I18n.t(
#         'pages.delete_modal.delete_page_used_for_branching_not_supported_message'
#       )
#     )
#   end

#   def then_I_should_see_a_message_that_is_not_possible_to_create_stack_branches
#     expect(page).to have_content(
#       I18n.t(
#         'pages.delete_modal.stack_branches_not_supported_message'
#       )
#     )
#   end

#   def and_I_want_to_delete_a_branch_destination_page
#     editor.flow_thumbnail('Page c').hover
#     and_I_click_on_the_three_dots
#     editor.delete_page_link.click
#   end

#   def when_I_delete_the_branch_destination_page
#     editor.delete_and_update_branching_link.click
#   end

#   def then_I_should_not_see_the_deleted_page_in_the_flow
#     expect(page).to_not have_content('Page c')
#   end

#   def and_I_should_see_the_new_destination_as_next_page_after_the_deleted_page
#     editor.click_branch('Branching point 1')
#     element = editor.destination_options.find('option[selected]')
#     expect(element.text).to eq('Page d')
#   end

#   def and_I_want_to_delete_the_page_that_I_created
#     editor.flow_thumbnail(question_title).hover
#     and_I_click_on_the_three_dots
#   end

#   def when_I_delete_the_page
#     editor.delete_page_link.click
#     and_I_click_delete
#   end

#   def try_to_delete_page(page_name)
#     editor.flow_thumbnail(page_name).hover
#     and_I_click_on_the_three_dots
#     editor.delete_page_link.click
#   end

#   def then_I_should_not_see_the_deleted_page_anymore
#     page.find(:css, '#flow-overview')
#     expect(editor.form_urls).to_not include(question_title)
#   end

#   def and_I_update_the_exit_page_question
#     editor.question_heading.first.set(exit_page_title)
#     when_I_save_my_changes
#   end

#   def given_I_set_the_exit_page_as_a_branch_destination
#     editor.click_branch('Branching point 1')
#     editor.otherwise_options.select(exit_page_title)
#     when_I_save_my_changes
#   end

#   def then_I_should_see_the_delete_page_no_default_next_modal
#     dialog = page.find('.ui-dialog')
#     expect(dialog).to have_content(
#       I18n.t(
#         'pages.delete_modal.delete_branch_destination_page_no_default_next_message'
#       )
#     )
#   end
# end
