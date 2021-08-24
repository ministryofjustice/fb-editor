require_relative '../spec_helper'

feature 'Branching errors' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'when all required fields are filled in' do
    given_I_add_all_pages_for_a_form_with_branching
    and_I_return_to_flow_page
    and_I_want_to_add_branching

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
    then_I_should_see_no_errors
  end

  scenario 'when no required fields are filled in' do
    given_I_add_all_pages_for_a_form_with_branching
    and_I_return_to_flow_page
    and_I_want_to_add_branching

    when_I_save_my_changes
    then_I_should_see_an_error_summary
    then_I_should_see_error_summary_errors(3)
    then_I_should_see_all_branching_error_messages
  end

  scenario 'when the "Go to" field is not filled in' do
    given_I_add_all_pages_for_a_form_with_branching
    and_I_return_to_flow_page
    and_I_want_to_add_branching

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
    then_I_should_see_error_summary_errors(1)
    then_I_should_see_branching_error_message('Select a destination for Branch 1')
  end

  # scenario 'when the conditional field is not filled in' do
  # end

  # scenario 'when the expression field is not filled in' do
  # end

  scenario 'when there are two branch objects' do
    given_I_add_all_pages_for_a_form_with_branching
    and_I_return_to_flow_page
    and_I_want_to_add_branching

    and_I_want_to_add_another_branch
    then_I_should_see_another_branch

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
    then_I_should_see_error_summary_errors(2)
    then_I_should_see_branching_error_message('Select a destination for Branch 2')
    then_I_should_see_branching_error_message('Select a question for the condition for Branch 2')
  end

  # Errors
  def then_I_should_see_all_branching_error_messages
    expect(page).to have_selector('.govuk-form-group--error', count: 3)
  end

  def then_I_should_see_an_error_summary
    expect(page).to have_selector('.govuk-error-summary')
  end

  def then_I_should_see_error_summary_errors(count)
    expect(find('ul.govuk-error-summary__list')).to have_selector('li', count: count)
  end

  def then_I_should_see_no_errors
    expect(page).not_to have_selector('.govuk-error-summary')
  end

  def then_I_should_see_branching_error_message(text)
    expect(page).to have_selector('.govuk-form-group--error', text: text)
  end

  # Branching options / selections
  def and_I_want_to_add_another_branch
    editor.add_another_branch.click
  end

  def then_I_should_see_another_branch
    expect(page).to have_selector('.Branch', count: 2)
  end

  def and_I_select_the_destination_page_dropdown
    editor.destination_options.click
  end

  def and_I_select_the_condition_dropdown
    editor.conditional_options.click
  end

  def then_I_should_see_statement_answers
    expect(editor).to have_operator_options
    expect(editor).to have_field_options
  end

  def and_I_select_the_field_dropdown
    editor.field_options.click
  end

  def and_I_select_the_operator_dropdown
    editor.operator_options.click
  end

  def and_I_select_the_otherwise_dropdown
    editor.otherwise_options.click
  end

  def then_I_should_see_the_correct_number_of_options(id, amount)
    options = find(id).all('option')
    expect(options.length).to eq(amount)
  end

  def and_I_choose_an_option(name, option)
    select(option, from: name)
  end

  # Branching page set up
  def given_I_add_all_pages_for_a_form_with_branching
    given_I_add_a_single_question_page_with_radio
    and_I_add_a_page_url('favourite-hobby')
    when_I_add_the_page
    when_I_update_the_question_name('What is your favourite hobby?')
    and_I_edit_the_option_items('Hiking', 'Sewing')
    and_I_return_to_flow_page

    given_I_add_a_single_question_page_with_checkboxes
    and_I_add_a_page_url('ice-cream')
    when_I_add_the_page
    when_I_update_the_question_name('Which flavours of ice cream have you eaten?')
    and_I_edit_the_option_items('Hokey Pokey', 'Chocolate')
    and_I_return_to_flow_page

    given_I_add_a_single_question_page_with_text
    and_I_add_a_page_url('hiking')
    when_I_add_the_page
    when_I_update_the_question_name('Favourite hiking destination')
    and_I_return_to_flow_page

    given_I_add_a_single_question_page_with_text
    and_I_add_a_page_url('sewing')
    when_I_add_the_page
    when_I_update_the_question_name('Favourite sewing project')
    and_I_return_to_flow_page

    given_I_add_a_check_answers_page
    and_I_add_a_page_url('cya')
    when_I_add_the_page
    and_I_return_to_flow_page

    given_I_add_a_confirmation_page
    and_I_add_a_page_url('confirmation')
    when_I_add_the_page
  end

  def when_I_update_the_question_name(question_name)
    editor.question_heading.first.set(question_name)
    when_I_save_my_changes
  end

  def and_I_edit_the_option_items(*item)
    editor.editable_options.first.set(item[0])
    editor.service_name.click
    editor.editable_options.last.set(item[1])
    editor.service_name.click
    when_I_save_my_changes
  end

  def and_I_want_to_add_branching
    editor.preview_page_images[1].hover # favourite-hobby page
    editor.three_dots_button.click
    editor.branching_link.click
    then_I_should_see_the_branching_page
  end

  def then_I_should_see_the_branching_page
    expect(editor.question_heading.first.text).to eq('Branching point 1')
  end
end
