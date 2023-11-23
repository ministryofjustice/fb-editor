require_relative '../spec_helper'

feature 'New branch page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:page_url) { 'What is your favourite hobby?' }

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(fixture: 'no_branches_fixture')
  end

  scenario 'when editing the branch page' do
    and_I_want_to_add_branching(page_url)

    then_I_should_see_the_branch_title(index: 0, title: 'Branch 1')
    then_I_should_see_the_operator(I18n.t('branches.expression.if'))
    then_I_should_not_see_text(I18n.t('branches.condition_remove'))

    and_I_select_the_destination_page_dropdown
    then_I_should_not_see_unconnected_pages
    editor.branches.conditional(0).destination_select.select('Favourite hiking destination')


    and_I_select_the_condition_dropdown
    editor.branches.conditional(0).expression(0).component_select.select('What is your favourite hobby?')

    then_I_should_see_the_add_condition_link

    and_I_select_the_otherwise_dropdown
    then_I_should_not_see_unconnected_pages
    and_I_choose_an_option(
      'branch[default_next]',
      'Which flavours of ice cream have you eaten?'
    )

    when_I_save_my_changes
    sleep(1)
    expect(page).not_to have_selector('.govuk-error-summary')
    then_I_can_add_conditionals_and_expressions

    editor.branches.conditional(0).expression(1).component_select.select('What is your favourite hobby?')
    sleep(0.5)

    editor.branches.conditional(0).expression(1).operator_select.select('is not')
    editor.branches.conditional(0).expression(1).answer_select.select('Sewing')

    when_I_save_my_changes
    then_I_should_not_see_an_error_summary

    then_I_should_see_the_field_option(
      'branch[conditionals_attributes][0][expressions_attributes][0][operator]',
      'is'
    )

    then_I_should_see_the_field_option(
      'branch[conditionals_attributes][0][expressions_attributes][0][field]',
      'Hiking'
    )

    then_I_should_see_the_field_option(
      'branch[conditionals_attributes][0][expressions_attributes][1][operator]',
      'is not'
    )

    then_I_should_see_the_field_option(
      'branch[conditionals_attributes][0][expressions_attributes][1][field]',
      'Sewing'
    )

    then_I_can_delete_conditionals_and_expressions

    editor.branches.conditional(0).expression(0).operator_select.select('is answered')
    then_I_should_not_see_field_options('branch[conditionals_attributes][0][expressions_attributes][0][field]')

    and_I_choose_an_option(
      'branch[conditionals_attributes][0][expressions_attributes][0][operator]',
      'is'
    )

    then_I_should_see_the_field_option(
      'branch[conditionals_attributes][0][expressions_attributes][0][field]',
      'Hiking'
    )

    and_I_choose_an_option(
      'branch[conditionals_attributes][0][expressions_attributes][0][field]',
      'Sewing'
    )

    when_I_save_my_changes
    then_I_should_see_the_previous_page_title('What is your favourite hobby?')

    then_I_should_see_the_field_option(
      'branch[conditionals_attributes][0][expressions_attributes][0][field]',
      'Hiking'
    )

    then_I_should_see_no_errors
  end

  scenario 'when editing with unconnected pages' do
    and_I_want_to_add_branching(page_url)

    then_I_should_see_the_branch_title(index: 0, title: 'Branch 1')
    then_I_should_see_the_operator(I18n.t('branches.expression.if'))
    then_I_should_not_see_text(I18n.t('branches.condition_remove'))

    and_I_select_the_destination_page_dropdown
    then_I_should_not_see_unconnected_pages
    editor.branches.conditional(0).destination_select.select('Favourite hiking destination')

    and_I_select_the_condition_dropdown
    editor.branches.conditional(0).expression(0).component_select.select('What is your favourite hobby?')

    then_I_should_see_the_add_condition_link

    and_I_select_the_otherwise_dropdown
    then_I_should_not_see_unconnected_pages
    and_I_choose_an_option(
      'branch[default_next]',
      'Check your answers'
    )

    when_I_save_my_changes
    then_I_should_be_on_the_correct_branch_page('edit')

    then_I_can_add_conditionals_and_expressions
    then_I_can_delete_conditionals_and_expressions

    when_I_save_my_changes
    then_I_should_see_the_previous_page_title('What is your favourite hobby?')
    then_I_should_see_no_errors

    then_I_should_have_unconnected_pages
    editor.branches.conditional(0).destination_select.select('Favourite hiking destination')

    and_I_select_the_condition_dropdown
    editor.branches.conditional(0).expression(0).component_select.select('What is your favourite hobby?')

    then_I_should_see_the_add_condition_link

    when_I_save_my_changes
    then_I_should_see_no_errors
  end
end
