require_relative '../spec_helper'

feature 'Branching errors' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'when no required fields are filled in' do
    given_I_add_all_pages_for_a_form_with_branching
    and_I_return_to_flow_page
    and_I_want_to_add_branching(1)

    when_I_save_my_changes
    then_I_should_see_an_error_summary
    then_I_should_see_error_summary_errors(3)
    then_I_should_see_branching_error_message('Select a destination for Branch 1')
    then_I_should_see_branching_error_message('Select a question for the condition for Branch 1')
    then_I_should_see_branching_error_message("Select a destination for 'Otherwise'")
  end

  scenario 'when the "Go to" field is not filled in' do
    given_I_add_all_pages_for_a_form_with_branching
    and_I_return_to_flow_page
    and_I_want_to_add_branching(1)

    and_I_select_the_condition_dropdown
    then_I_should_see_the_correct_number_of_options(
      '#branch_conditionals_attributes_0_expressions_attributes_0_component',
      5
    )
    and_I_choose_an_option(
      'branch[conditionals_attributes][0][expressions_attributes][0][component]',
      'What is your favourite hobby?'
    )
    then_I_should_see_statement_answers

    and_I_select_the_operator_dropdown
    and_I_choose_an_option(
      'branch[conditionals_attributes][0][expressions_attributes][0][operator]',
      'is'
    )

    and_I_select_the_field_dropdown
    then_I_should_see_the_correct_number_of_options(
      '#branch_conditionals_attributes_0_expressions_attributes_0_field',
      2
    )
    and_I_choose_an_option(
      'branch[conditionals_attributes][0][expressions_attributes][0][field]',
      'Hiking'
    )

    and_I_select_the_otherwise_dropdown
    then_I_should_see_the_correct_number_of_options(
      '#branch_default_next',
      8
    )
    and_I_choose_an_option(
      'branch[default_next]',
      'Which flavours of ice cream have you eaten?'
    )

    when_I_save_my_changes
    then_I_should_see_an_error_summary
    then_I_should_see_error_summary_errors(1)
    then_I_should_see_branching_error_message('Select a destination for Branch 1')
  end

  scenario 'when the Otherwise/default next field is not filled in' do
    given_I_add_all_pages_for_a_form_with_branching
    and_I_return_to_flow_page
    and_I_want_to_add_branching(1)

    and_I_select_the_destination_page_dropdown
    then_I_should_see_the_correct_number_of_options(
      '#branch_conditionals_attributes_0_next',
      8
    )
    and_I_choose_an_option(
      'branch[conditionals_attributes][0][next]',
      'Favourite hiking destination'
    )

    and_I_select_the_condition_dropdown
    then_I_should_see_the_correct_number_of_options(
      '#branch_conditionals_attributes_0_expressions_attributes_0_component',
      5
    )
    and_I_choose_an_option(
      'branch[conditionals_attributes][0][expressions_attributes][0][component]',
      'What is your favourite hobby?'
    )
    then_I_should_see_statement_answers

    and_I_select_the_operator_dropdown
    and_I_choose_an_option(
      'branch[conditionals_attributes][0][expressions_attributes][0][operator]',
      'is'
    )

    and_I_select_the_field_dropdown
    then_I_should_see_the_correct_number_of_options(
      '#branch_conditionals_attributes_0_expressions_attributes_0_field',
      2
    )
    and_I_choose_an_option(
      'branch[conditionals_attributes][0][expressions_attributes][0][field]',
      'Hiking'
    )

    when_I_save_my_changes
    then_I_should_see_an_error_summary
    then_I_should_see_error_summary_errors(1)
    then_I_should_see_branching_error_message("Select a destination for 'Otherwise'")
  end

  scenario 'when there are two conditional objects to a branching point' do
    given_I_add_all_pages_for_a_form_with_branching
    and_I_return_to_flow_page
    and_I_want_to_add_branching(1)

    and_I_want_to_add_another_conditional
    then_I_should_see_another_conditional

    and_I_select_the_destination_page_dropdown
    then_I_should_see_the_correct_number_of_options(
      '#branch_conditionals_attributes_0_next',
      8
    )
    and_I_choose_an_option(
      'branch[conditionals_attributes][0][next]',
      'Favourite hiking destination'
    )

    and_I_select_the_condition_dropdown
    then_I_should_see_the_correct_number_of_options(
      '#branch_conditionals_attributes_0_expressions_attributes_0_component',
      5
    )
    and_I_choose_an_option(
      'branch[conditionals_attributes][0][expressions_attributes][0][component]',
      'What is your favourite hobby?'
    )
    then_I_should_see_statement_answers

    and_I_select_the_operator_dropdown
    and_I_choose_an_option(
      'branch[conditionals_attributes][0][expressions_attributes][0][operator]',
      'is'
    )

    and_I_select_the_field_dropdown
    then_I_should_see_the_correct_number_of_options(
      '#branch_conditionals_attributes_0_expressions_attributes_0_field',
      2
    )
    and_I_choose_an_option(
      'branch[conditionals_attributes][0][expressions_attributes][0][field]',
      'Hiking'
    )

    and_I_select_the_otherwise_dropdown
    then_I_should_see_the_correct_number_of_options(
      '#branch_default_next',
      8
    )
    and_I_choose_an_option(
      'branch[default_next]',
      'Which flavours of ice cream have you eaten?'
    )

    when_I_save_my_changes
    then_I_should_see_an_error_summary
    then_I_should_see_error_summary_errors(2)
    then_I_should_see_branching_error_message('Select a destination for Branch 2')
    then_I_should_see_branching_error_message('Select a question for the condition for Branch 2')
  end

  # Errors
  def then_I_should_see_an_error_summary
    expect(page).to have_selector('.govuk-error-summary')
  end

  def then_I_should_see_error_summary_errors(count)
    expect(find('ul.govuk-error-summary__list')).to have_selector('li', count: count)
  end

  def then_I_should_see_branching_error_message(text)
    expect(page).to have_selector('.govuk-form-group--error', text: text)
  end

  # Branching options / selections
  def and_I_want_to_add_another_conditional
    # the UI says 'Add another branch' even though it's a conditional
    editor.add_another_branch.click
  end

  def then_I_should_see_another_conditional
    expect(page).to have_selector('.Branch', count: 2)
  end
end
