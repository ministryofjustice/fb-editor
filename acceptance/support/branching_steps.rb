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

  def then_I_can_add_and_delete_conditionals_and_expressions
    and_I_add_another_condition
    then_I_should_see_the_operator(I18n.t('branches.expression.and'))
    then_I_should_see_another_question_list
    then_I_should_see_the_delete_condition_button

    and_I_delete_the_condition
    then_I_should_not_see_the_operator(I18n.t('branches.expression.and'))
    then_I_should_not_see_text(I18n.t('branches.condition_remove'))

    and_I_add_another_branch
    then_I_should_see_the_branch_title(index: 1, title: 'Branch 2')

    and_I_delete_the_branch(1)
    then_I_should_not_see_text('Branch 2')
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

  def and_I_want_to_add_branching(url)
    page.find('.flow-thumbnail', text: url).hover
    editor.three_dots_button.click
    editor.branching_link.click
    then_I_should_see_the_branching_page
  end

  def then_I_should_see_the_branching_page
    expect(editor.question_heading.first.text).to eq(
      I18n.t('default_values.branching_title', branching_number: 1)
    )
  end

  def and_I_select_the_destination_page_dropdown
    editor.destination_options.click
  end

  def then_I_should_not_see_unconnected_pages
    expect(editor).not_to have_selector('.branch-optgroup')
  end

  def then_I_should_have_unconnected_pages
    expect(editor.find('#branch_default_next .branch-optgroup').visible?).to be_truthy
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

  def then_I_should_see_no_errors
    expect(page).not_to have_selector('.govuk-error-summary')
  end

  def then_I_should_be_on_the_correct_branch_page(path)
    expect(URI(current_url).path.split('/').last).to eq(path)
  end

  def and_I_add_another_condition
    editor.add_condition.click
  end

  def and_I_delete_the_condition
    editor.remove_condition.click
    editor.remove_condition_button.click
  end

  def and_I_add_another_branch
    editor.add_another_branch.click
  end

  def and_I_delete_the_branch(index)
    editor.find("div[data-conditional-index='#{index}'] button").click
    editor.find('a.branch-remover').click
    editor.remove_branch_button.click
  end

  def then_I_should_see_the_operator(text)
    page_with_css('div.question label.govuk-label', text)
  end

  def page_with_css(element, text)
    expect(page).to have_css(element, text: text)
  end

  def page_without_css(element, text)
    expect(page).not_to have_css(element, text: text)
  end

  def then_I_should_see_another_question_list
    then_I_should_see_text(I18n.t('branches.expression.and'))
    then_I_should_see_text(I18n.t('branches.select_question'))
  end

  def then_I_should_not_see_text(text)
    expect(page).not_to have_text(text)
  end

  def then_I_should_see_text(text)
    expect(page).to have_text(text)
  end

  def then_I_should_see_the_add_condition_link
    # wait for the api call to get the operators and answers
    sleep(2)
    expect(page).to have_text(I18n.t('branches.condition_add'))
  end

  def then_I_should_not_see_the_delete_condition_button
    page_without_css('button.condition-remove', I18n.t('branches.condition_remove'))
  end

  def then_I_should_see_the_delete_condition_button
    page_with_css('button.condition-remover', I18n.t('branches.condition_remove'))
  end

  def then_I_should_not_see_the_operator(text)
    page_without_css('div.question label.govuk-label', text)
  end

  def then_I_should_see_the_branch_title(index:, title:)
    expect(editor.branch_title(index).text).to eq(title)
  end

  def then_I_should_see_the_previous_page_title(page_title)
    expect(editor).to have_text(page_title)
  end
end
