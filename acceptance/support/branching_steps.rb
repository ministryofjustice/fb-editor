module BranchingSteps
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

  def and_I_want_to_add_branching(index)
    editor.preview_page_images[index].hover
    editor.three_dots_button.click
    editor.branching_link.click

    then_I_should_see_the_branching_page
  end

  def then_I_should_see_the_branching_page
    expect(editor.question_heading.first.text).to eq('Branching point 1')
  end

  def and_I_select_the_destination_page_dropdown
    editor.destination_options.click
  end

  def then_I_should_see_the_correct_number_of_options(id, amount)
    options = find(id).all('option')
    expect(options.length).to eq(amount)
  end

  def and_I_choose_an_option(name, option)
    select(option, from: name)
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
end
