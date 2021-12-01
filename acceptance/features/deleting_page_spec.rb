require_relative '../spec_helper'

feature 'Deleting page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:page_url) { 'dooku' }

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'when deleting other pages' do
    given_I_have_a_single_question_page_with_text
    and_I_return_to_flow_page
    and_I_want_to_delete_the_page_that_I_created
    when_I_delete_the_page
    sleep 0.5 # Allow time for the page to reload after deleting the page
    then_I_should_not_see_the_deleted_page_anymore
  end

  scenario 'when try to delete a page which has a branching conditional' do
    given_I_have_a_form_with_pages
    when_I_try_to_delete_a_page_which_has_a_branching_conditional
    then_I_should_see_a_message_that_is_not_possible_to_delete_the_page
  end

  scenario 'when try to delete a page which result with a stack branch' do
    given_I_have_a_form_with_pages
    when_I_try_to_delete_a_page_which_result_in_a_stack_branch
    then_I_should_see_a_message_that_is_not_possible_to_create_stack_branches
  end

  scenario 'when try to delete a page which is a branch destination' do
    pending
  end

  scenario 'when deleting a branch' do
    given_I_have_a_form_with_pages
    and_I_click_to_delete_branching_point_one
    and_I_choose_page_c_to_connect_the_forms
    when_I_delete_the_branching_point
    then_I_should_see_page_c_connected_in_the_main_flow
    and_I_should_see_the_other_pages_as_unconnected
  end

  def given_I_have_a_form_with_pages
    given_I_have_a_page('page-b')
    given_I_have_a_page('page-c')
    given_I_have_a_page('page-d')
    given_I_have_a_page('page-e')
    given_I_have_a_page('page-f')
    given_I_have_a_page('page-g')
    given_I_have_a_page('page-h')
    given_I_have_a_page('page-i')
    given_I_have_a_page('page-j')
    given_I_have_a_branching_point_one
    given_I_have_a_branching_point_two
  end

  def given_I_have_a_page(url)
    given_I_add_a_single_question_page_with_checkboxes
    and_I_add_a_page_url(url)
    when_I_add_the_page
    editor.question_heading.first.set(url.underscore.humanize)
    and_I_edit_the_option_items('Thor', 'Hulk')
    and_I_return_to_flow_page
  end

  def given_I_have_a_branching_point_one
    editor.hover_preview('Page b')
    editor.three_dots_button.click
    and_I_add_branching_to_the_page

    # Go to page c if Page b is Thor
    editor.destination_options.select('Page c')
    editor.conditional_options.select('Page b')
    editor.operator_options.select('is')
    editor.field_options.select('Thor')

    # Go to Page e if Page b is Hulk
    and_I_add_another_branch
    editor.second_destination_options.select('Page e')
    editor.second_conditional_options.select('Page b')
    editor.second_operator_options.select('is')
    editor.second_field_options.select('Hulk')

    # Otherise go to Page g
    editor.otherwise_options.select('Page g')

    editor.save_button.click
    and_I_return_to_flow_page
  end

  def given_I_have_a_branching_point_two
    editor.preview_page_images.first.hover
    editor.hover_preview('Page g')
    editor.three_dots_button.click
    and_I_add_branching_to_the_page

    # Go to page h if Page g is Thor
    editor.destination_options.select('Page h')
    editor.conditional_options.select('Page g')
    editor.operator_options.select('is')
    editor.field_options.select('Thor')
    #
    # Otherise go to Page i
    editor.otherwise_options.select('Page i')

    editor.save_button.click
    and_I_return_to_flow_page
  end

  def when_I_try_to_delete_a_page_which_has_a_branching_conditional
    try_to_delete_page('Page b')
  end

  def when_I_try_to_delete_a_page_which_result_in_a_stack_branch
    try_to_delete_page('Page g')
  end

  def then_I_should_see_a_message_that_is_not_possible_to_delete_the_page
    expect(editor.text).to include(
      'You cannot delete this page because it is used in a branching condition'
    )
  end

  def then_I_should_see_a_message_that_is_not_possible_to_create_stack_branches
    expect(editor.text).to include(
      'Deleting this page would result in 2 branching points in a row, which is not currently possible. Try combining your branching rules into 1 branching point.'
    )
  end

  def and_I_want_to_delete_the_page_that_I_created
    editor.preview_page_images.last.hover
    editor.three_dots_button.click
  end

  def when_I_delete_the_page
    editor.delete_page_link.click
    sleep 0.5 # Arbitrary delay, possibly required due to focus issues
    editor.delete_page_modal_button.click
  end

  def try_to_delete_page(page_name)
    editor.hover_preview(page_name)
    editor.three_dots_button.click
    editor.delete_page_link.click
    sleep 0.5 # Arbitrary delay, possibly required due to focus issues
  end


  def then_I_should_not_see_the_deleted_page_anymore
    expect(editor.form_urls.count).to eq(1)
  end
end
