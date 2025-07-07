# module BranchingSteps
#   # Branching page set up
#   def given_I_add_all_pages_for_a_form_with_branching
#     given_I_add_a_single_question_page_with_radio
#     and_I_add_a_page_url('favourite-hobby')
#     when_I_add_the_page
#     when_I_update_the_question_name('What is your favourite hobby?')
#     and_I_edit_the_option_items('Hiking', 'Sewing')
#     and_I_return_to_flow_page

#     given_I_add_a_single_question_page_with_checkboxes
#     and_I_add_a_page_url('ice-cream')
#     when_I_add_the_page
#     when_I_update_the_question_name('Which flavours of ice cream have you eaten?')
#     and_I_edit_the_option_items('Hokey Pokey', 'Chocolate')
#     and_I_return_to_flow_page

#     given_I_add_a_single_question_page_with_text
#     and_I_add_a_page_url('hiking')
#     when_I_add_the_page
#     when_I_update_the_question_name('Favourite hiking destination')
#     and_I_return_to_flow_page

#     given_I_add_a_single_question_page_with_text
#     and_I_add_a_page_url('sewing')
#     when_I_add_the_page
#     when_I_update_the_question_name('Favourite sewing project')
#     and_I_return_to_flow_page
#   end

#   def then_I_can_add_conditionals_and_expressions
#     and_I_add_another_condition
#     then_I_should_see_the_operator(I18n.t('branches.expression.and'))
#     then_I_should_see_another_question_list
#     then_I_should_see_multiple_delete_condition_buttons
#   end

#   def then_I_can_delete_conditionals_and_expressions
#     and_I_delete_the_last_condition
#     then_I_should_not_see_the_operator(I18n.t('branches.expression.and'))
#     then_I_should_not_see_text(I18n.t('branches.condition_remove'))

#     and_I_add_another_branch
#     then_I_should_see_the_branch_title(index: 1, title: 'Branch 2')

#     and_I_delete_the_branch(1)
#     expect( editor.branches ).to have_conditionals(count: 1)
#   end

#   def when_I_update_the_question_name(question_name)
#     editor.question_heading.first.set(question_name)
#     when_I_save_my_changes
#   end

#   def and_I_edit_the_option_items(*item)
#     editor.editable_options.first.set(item[0])
#     editor.service_name.click
#     editor.editable_options.last.set(item[1])
#     editor.service_name.click
#     when_I_save_my_changes
#   end

#   def and_I_want_to_add_branching(url)
#     editor.connection_menu(url).click
#     and_I_add_branching_to_the_page
#     then_I_should_see_the_branching_page
#   end

#   def and_I_add_branching_to_the_page
#     editor.branching_link.click
#   end

#   def then_I_should_see_the_branching_page
#     expect(editor.page_heading.text).to eq(
#       I18n.t('default_values.branching_title', branching_number: 1)
#     )
#   end

#   def and_I_select_the_destination_page_dropdown
#     editor.destination_options.click
#   end

#   def then_I_should_not_see_unconnected_pages
#     expect(editor).not_to have_selector('.branch-optgroup')
#   end

#   def then_I_should_have_unconnected_pages
#     expect(editor.find('#branch_default_next .branch-optgroup').visible?).to be_truthy
#   end

#   def then_I_should_see_the_correct_number_of_options(id, amount)
#     options = find(id).all('option')
#     expect(options.length).to eq(amount)
#   end

#   def then_I_should_not_see_field_options(name)
#     expect(page).to have_no_select(name)
#   end

#   def then_I_should_see_the_field_option(name, text)
#     expect(page).to have_select(name, text: text)
#   end

#   def and_I_choose_an_option(name, option)
#     select(option, from: name)
#   end

#   def and_I_select_the_condition_dropdown
#     editor.conditional_options.click
#   end

#   def then_I_should_see_statement_answers
#     expect(editor).to have_operator_options
#     expect(editor).to have_field_options
#   end

#   def and_I_select_the_field_dropdown
#     editor.field_options.click
#   end

#   def and_I_select_the_operator_dropdown
#     editor.operator_options.click
#   end

#   def and_I_select_the_otherwise_dropdown
#     editor.otherwise_options.click
#   end

#   def then_I_should_see_no_errors
#     expect(page).not_to have_selector('.govuk-error-summary')
#   end

#   def then_I_should_be_on_the_correct_branch_page(path)
#     expect(URI(current_url).path.split('/').last).to eq(path)
#   end

#   def and_I_add_another_condition
#     editor.add_condition.click
#   end

#   def and_I_delete_the_last_condition
#     editor.last_condition_remover.click
#     within('.Dialog') do
#       editor.remove_condition_button.click
#     end
#   end

#   def and_I_add_another_branch
#     editor.add_another_branch.click
#   end

#   def and_I_delete_the_branch(index)
#     editor.branches.conditional(index).delete_button.click
#     within('.Dialog') do
#       editor.remove_branch_button.click
#     end
#   end

#   def then_I_should_see_the_operator(text)
#     page_with_css('.expression [data-expression-target="label"]', text)
#   end

#   def page_with_css(element, text)
#     expect(page).to have_css(element, text: text)
#   end

#   def page_without_css(element, text)
#     expect(page).not_to have_css(element, text: text)
#   end

#   def then_I_should_see_another_question_list
#     then_I_should_see_text(I18n.t('branches.expression.and'))
#     then_I_should_see_text(I18n.t('branches.select_question'))
#   end

#   def then_I_should_not_see_text(text)
#     expect(page).not_to have_text(text)
#   end

#   def then_I_should_see_text(text)
#     expect(page).to have_text(text)
#   end

#   def then_I_should_see_the_add_condition_link
#     expect(page).to have_content(I18n.t('branches.condition_add'))
#   end

#   def then_I_should_not_see_the_delete_condition_button
#     page_without_css('button.condition-remove', I18n.t('branches.condition_remove'))
#   end

#   def then_I_should_see_the_delete_condition_button
#     page_with_css('button.expression__remover', I18n.t('branches.condition_remove'))
#   end

#   def then_I_should_see_multiple_delete_condition_buttons
#     expect(page).to have_css("button.expression__remover", :minimum => 2)
#   end

#   def then_I_should_not_see_the_operator(text)
#     page_without_css('div.question label.govuk-label', text)
#   end

#   def then_I_should_see_the_branch_title(index:, title:)
#     expect(editor.branches.conditional(index).title).to have_text(title)
#   end

#   def then_I_should_see_the_previous_page_title(page_title)
#     expect(editor).to have_text(page_title)
#   end

#   def given_I_have_a_page(url)
#     given_I_add_a_single_question_page_with_checkboxes
#     and_I_add_a_page_url(url)
#     when_I_add_the_page
#     editor.question_heading.first.set(url.underscore.humanize)
#     and_I_edit_the_option_items('Thor', 'Hulk')
#     and_I_return_to_flow_page
#   end

#   def given_I_have_a_multiquestion_page(url)
#     given_I_add_a_multiple_question_page
#     and_I_add_a_page_url(url)
#     when_I_add_the_page
#     editor.question_heading.first.set(url.underscore.humanize)

#     and_I_add_the_component(I18n.t('components.list.radios'))
#     and_I_add_the_component(I18n.t('components.list.checkboxes'))

#     and_I_change_the_component(
#       'Question 1',
#       component: 0,
#       tag: 'legend',
#       options: ['Thanos']
#     )
#     and_I_change_the_component(
#       'Question 2',
#       component: 1,
#       tag: 'legend',
#       options: ['Thor','Hulk'],
#     )

#     when_I_save_my_changes
#     and_I_return_to_flow_page
#   end

#   def given_I_have_a_branching_point_one
#     editor.connection_menu('Page b').click
#     and_I_add_branching_to_the_page

#     # Go to page c if Page b is Thor
#     editor.destination_options.select('Page c')
#     editor.conditional_options.select('Page b')
#     editor.operator_options.select('contains')
#     editor.field_options.select('Thor')

#     # Go to Page e if Page b is Hulk
#     and_I_add_another_branch
#     editor.second_destination_options.select('Page e')
#     editor.second_conditional_options.select('Page b')
#     editor.second_operator_options.select('contains')
#     editor.second_field_options.select('Hulk')

#     # Otherise go to Page g
#     editor.otherwise_options.select('Page g')

#     editor.save_button.click
#     and_I_return_to_flow_page
#     expect(editor).to have_content('Branching point 1')
#   end

#   def given_I_have_a_branching_point_two
#     editor.connection_menu('Page g').click
#     and_I_add_branching_to_the_page

#     # Go to page h if Page g is Thor
#     editor.destination_options.select('Page h')
#     editor.conditional_options.select('Question 1')
#     editor.operator_options.select('is')
#     editor.conditional_options.select('Question 2')
#     editor.operator_options.select('contains')
#     editor.field_options.select('Thor')
#     #
#     # Otherise go to Page i
#     editor.otherwise_options.select('Page i')

#     editor.save_button.click
#     and_I_return_to_flow_page
#   end

#   # Error summary #
#   def then_I_should_not_see_an_error_summary
#     expect(page).not_to have_selector('.govuk-error-summary')
#   end
# end
