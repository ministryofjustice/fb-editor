require_relative '../spec_helper'

feature 'Component validations' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:fixture) { 'all_component_types_fixture' }

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(name: service_name, fixture: fixture)
  end

  scenario 'minimum validation' do
    and_I_visit_a_page('Number')
    when_I_want_to_select_question_properties
    then_I_should_see_the_minimum_and_maximum_validations

    and_I_select_a_validation(I18n.t('question.menu.minimum'))
    then_I_should_see_the_validation_modal(
      I18n.t('dialogs.component_validations.minimum.label'),
      I18n.t('dialogs.component_validations.minimum.status_label')
    )

    and_I_enable_the_validation
    click_button(I18n.t('dialogs.component_validations.button'))
    then_I_should_see_an_error_message(
      I18n.t(
      'activemodel.errors.models.base_component_validation.blank',
      label: I18n.t('dialogs.component_validations.minimum.label')
    ))

    and_I_set_the_input_value('5')
    click_button(I18n.t('dialogs.component_validations.button'))
    then_I_should_not_see_the_validation_modal(
      I18n.t('dialogs.component_validations.minimum.label'),
      I18n.t('dialogs.component_validations.minimum.status_label')
    )

    when_I_want_to_select_question_properties
    and_I_select_a_validation(I18n.t('question.menu.minimum'))
    then_I_should_see_the_previously_set_configuration('5')
    and_I_set_the_input_value('3')
    click_button(I18n.t('dialogs.component_validations.button'))

    click_button(I18n.t('actions.save'))
    when_I_want_to_select_question_properties
    and_I_select_a_validation(I18n.t('question.menu.minimum'))
    then_I_should_see_the_previously_set_configuration('3')
    click_button(I18n.t('dialogs.button_cancel'))

    and_I_return_to_flow_page
    preview = when_I_preview_the_page('Number')
    then_I_should_preview_the_number_page(
      preview: preview,
      first_value: '1',
      second_value: '20',
      error_message: 'Enter a higher number for Number'
    )
  end

  scenario 'maximum validation' do
    and_I_visit_a_page('Number')
    when_I_want_to_select_question_properties
    then_I_should_see_the_minimum_and_maximum_validations

    and_I_select_a_validation(I18n.t('question.menu.maximum'))
    then_I_should_see_the_validation_modal(
      I18n.t('dialogs.component_validations.maximum.label'),
      I18n.t('dialogs.component_validations.maximum.status_label')
    )

    and_I_enable_the_validation
    click_button(I18n.t('dialogs.component_validations.button'))
    then_I_should_see_an_error_message(
      I18n.t(
      'activemodel.errors.models.base_component_validation.blank',
      label: I18n.t('dialogs.component_validations.maximum.label')
    ))

    and_I_set_the_input_value('100')
    click_button(I18n.t('dialogs.component_validations.button'))
    then_I_should_not_see_the_validation_modal(
      I18n.t('dialogs.component_validations.maximum.label'),
      I18n.t('dialogs.component_validations.maximum.status_label')
    )

    when_I_want_to_select_question_properties
    and_I_select_a_validation(I18n.t('question.menu.maximum'))
    then_I_should_see_the_previously_set_configuration('100')
    and_I_set_the_input_value('50')
    click_button(I18n.t('dialogs.component_validations.button'))

    click_button(I18n.t('actions.save'))
    when_I_want_to_select_question_properties
    and_I_select_a_validation(I18n.t('question.menu.maximum'))
    then_I_should_see_the_previously_set_configuration('50')
    click_button(I18n.t('dialogs.button_cancel'))

    and_I_return_to_flow_page
    preview = when_I_preview_the_page('Number')
    then_I_should_preview_the_number_page(
      preview: preview,
      first_value: '100',
      second_value: '5',
      error_message: 'Enter a lower number for Number'
    )
  end

  scenario 'date after validation' do
    and_I_visit_a_page('Date')
    when_I_want_to_select_question_properties
    then_I_should_see_the_date_before_and_after_validations

    and_I_select_a_validation(I18n.t('question.menu.date_after'))
    then_I_should_see_the_validation_modal(
      I18n.t('dialogs.component_validations.date_after.label'),
      I18n.t('dialogs.component_validations.date_after.status_label')
    )

    and_I_enable_the_validation
    and_I_set_the_date_input_value('day', '10')
    and_I_set_the_date_input_value('month', '11')
    click_button(I18n.t('dialogs.component_validations.button'))
    then_I_should_see_an_error_message(
      I18n.t(
      'activemodel.errors.models.date_validation.missing_attribute',
      label: 'Earliest date',
      attribute: I18n.t('dialogs.component_validations.date.year').downcase
    ))

    and_I_set_the_date_input_value('year', 'this is not a year')
    click_button(I18n.t('dialogs.component_validations.button'))
    then_I_should_see_an_error_message(
      I18n.t(
      'activemodel.errors.models.date_validation.invalid',
      label: I18n.t('dialogs.component_validations.date_after.label')
    ))

    and_I_set_the_date_input_value('year', '2001')
    click_button(I18n.t('dialogs.component_validations.button'))
    then_I_should_not_see_the_validation_modal(
      I18n.t('dialogs.component_validations.date_after.label'),
      I18n.t('dialogs.component_validations.date_after.status_label')
    )

    when_I_want_to_select_question_properties
    and_I_select_a_validation(I18n.t('question.menu.date_after'))
    then_I_should_see_the_previously_set_date_configuration('day', '10')
    then_I_should_see_the_previously_set_date_configuration('month', '11')
    then_I_should_see_the_previously_set_date_configuration('year', '2001')

    and_I_set_the_date_input_value('day', '28')
    and_I_set_the_date_input_value('month', '2')
    and_I_set_the_date_input_value('year', '1999')
    click_button(I18n.t('dialogs.component_validations.button'))

    click_button(I18n.t('actions.save'))
    when_I_want_to_select_question_properties
    and_I_select_a_validation(I18n.t('question.menu.date_after'))
    then_I_should_see_the_previously_set_date_configuration('day', '28')
    then_I_should_see_the_previously_set_date_configuration('month', '02')
    then_I_should_see_the_previously_set_date_configuration('year', '1999')
    click_button(I18n.t('dialogs.button_cancel'))

    and_I_return_to_flow_page
    preview = when_I_preview_the_page('Date')
    then_I_should_preview_the_date_page(
      preview: preview,
      first_date: { day: '1', month: '2', year: '1901' },
      second_date: { day: '28', month: '2', year: '2001' },
      error_message: 'Enter a later date for Date'
    )
  end

  scenario 'date before validation' do
    and_I_visit_a_page('Date')
    when_I_want_to_select_question_properties
    then_I_should_see_the_date_before_and_after_validations

    and_I_select_a_validation(I18n.t('question.menu.date_before'))
    then_I_should_see_the_validation_modal(
      I18n.t('dialogs.component_validations.date_before.label'),
      I18n.t('dialogs.component_validations.date_before.status_label')
    )

    and_I_enable_the_validation
    and_I_set_the_date_input_value('month', '6')
    and_I_set_the_date_input_value('year', '2050')
    click_button(I18n.t('dialogs.component_validations.button'))
    then_I_should_see_an_error_message(
      I18n.t(
      'activemodel.errors.models.date_validation.missing_attribute',
      label: 'Latest date',
      attribute: I18n.t('dialogs.component_validations.date.day').downcase
    ))

    and_I_set_the_date_input_value('day', '30')
    click_button(I18n.t('dialogs.component_validations.button'))
    then_I_should_not_see_the_validation_modal(
      I18n.t('dialogs.component_validations.date_before.label'),
      I18n.t('dialogs.component_validations.date_before.status_label')
    )

    when_I_want_to_select_question_properties
    and_I_select_a_validation(I18n.t('question.menu.date_before'))
    then_I_should_see_the_previously_set_date_configuration('day', '30')
    then_I_should_see_the_previously_set_date_configuration('month', '06')
    then_I_should_see_the_previously_set_date_configuration('year', '2050')

    and_I_set_the_date_input_value('day', '14')
    and_I_set_the_date_input_value('month', '8')
    and_I_set_the_date_input_value('year', '2045')
    click_button(I18n.t('dialogs.component_validations.button'))

    click_button(I18n.t('actions.save'))
    when_I_want_to_select_question_properties
    and_I_select_a_validation(I18n.t('question.menu.date_before'))
    then_I_should_see_the_previously_set_date_configuration('day', '14')
    then_I_should_see_the_previously_set_date_configuration('month', '08')
    then_I_should_see_the_previously_set_date_configuration('year', '2045')
    click_button(I18n.t('dialogs.button_cancel'))

    and_I_return_to_flow_page
    preview = when_I_preview_the_page('Date')
    then_I_should_preview_the_date_page(
      preview: preview,
      first_date: { day: '1', month: '2', year: '2050' },
      second_date: { day: '28', month: '2', year: '2001' },
      error_message: 'Enter an earlier date for Date'
    )
  end

  def and_I_visit_a_page(flow_title)
    editor.flow_thumbnail(flow_title).click
  end

  def and_I_select_a_validation(validation_menu_text)
    page.find(:css, 'span', text: validation_menu_text).click
  end

  def and_I_enable_the_validation
    page.find(:css, 'input#component_validation_status', visible: false).set(true)
  end

  def and_I_set_the_input_value(value)
    page.find(:css, 'input#component_validation_value').set(value)
  end

  def when_I_preview_the_page(flow_title)
    editor.flow_thumbnail(flow_title).hover
    when_I_click_preview_page
  end

  def and_I_set_the_date_input_value(field, value)
    sleep(0.5)
    page.fill_in("component_validation[#{field}]", with: value)
  end

  def then_I_should_see_the_minimum_and_maximum_validations
    expect(editor.text).to include(I18n.t('question.menu.minimum'))
    expect(editor.text).to include(I18n.t('question.menu.maximum'))
  end

  def then_I_should_see_the_validation_modal(label, status_label)
    sleep(1)
    expect(page.text).to include(label)
    expect(page.text).to include(status_label)
  end

  def then_I_should_see_an_error_message(error_message)
    sleep(1)
    expect(page.text).to include(error_message)
  end

  def then_I_should_not_see_an_error_message(error_message)
    sleep(1)
    expect(page.text).to_not include(error_message)
  end

  def then_I_should_not_see_the_validation_modal(label, status_label)
    sleep(1)
    expect(page.text).to_not include(label)
    expect(page.text).to_not include(status_label)
  end

  def then_I_should_see_the_previously_set_configuration(value)
    sleep(0.5)
    expect(page.find(:css, 'input#component_validation_value').value).to eq(value)
  end

  def then_I_should_preview_the_number_page(preview:, first_value:, second_value:, error_message:)
    within_window(preview) do
      page.find_field('answers[number_number_1]').set(first_value)
      click_button(I18n.t('actions.continue'))
      then_I_should_see_an_error_message(error_message)
      page.find_field('answers[number_number_1]').set(second_value)
      click_button(I18n.t('actions.continue'))
      then_I_should_not_see_an_error_message(error_message)
    end
  end

  def then_I_should_see_the_date_before_and_after_validations
    expect(editor.text).to include(I18n.t('question.menu.date_before'))
    expect(editor.text).to include(I18n.t('question.menu.date_after'))
  end

  def then_I_should_see_the_previously_set_date_configuration(field, value)
    sleep(0.5)
    expect(page.find_field("component_validation[#{field}]").value).to eq(value)
  end

  def then_I_should_preview_the_date_page(preview:, first_date:, second_date:, error_message:)
    within_window(preview) do
      page.fill_in('answers[date_date_1(3i)]', with: first_date[:day])
      page.fill_in('answers[date_date_1(2i)]', with: first_date[:month])
      page.fill_in('answers[date_date_1(1i)]', with: first_date[:year])
      click_button(I18n.t('actions.continue'))
      then_I_should_see_an_error_message(error_message)

      page.fill_in('answers[date_date_1(3i)]', with: second_date[:day])
      page.fill_in('answers[date_date_1(2i)]', with: second_date[:month])
      page.fill_in('answers[date_date_1(1i)]', with: second_date[:year])
      click_button(I18n.t('actions.continue'))
      then_I_should_not_see_an_error_message(error_message)
    end
  end
end
