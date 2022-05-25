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
    then_I_should_preview_the_page(
      preview: preview,
      field: 'answers[number_number_1]',
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
    then_I_should_preview_the_page(
      preview: preview,
      field: 'answers[number_number_1]',
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

  scenario 'min length (characters)' do
    and_I_visit_a_page('Text')
    when_I_want_to_select_question_properties
    then_I_should_see_the_string_length_validations

    and_I_select_a_validation(I18n.t('question.menu.min_string_length'))
    then_I_should_see_the_validation_modal(
      I18n.t('dialogs.component_validations.string.min.label'),
      I18n.t('dialogs.component_validations.string.min.status_label')
    )

    and_I_enable_the_validation
    click_button(I18n.t('dialogs.component_validations.button'))
    then_I_should_see_an_error_message(
      I18n.t(
      'activemodel.errors.models.base_component_validation.blank',
      label: I18n.t('dialogs.component_validations.string.min.label')
    ))

    and_I_set_the_input_value('5')
    click_button(I18n.t('dialogs.component_validations.button'))
    then_I_should_not_see_the_validation_modal(
      I18n.t('dialogs.component_validations.string.min.label'),
      I18n.t('dialogs.component_validations.string.min.status_label')
    )

    when_I_want_to_select_question_properties
    and_I_select_a_validation(I18n.t('question.menu.min_string_length'))
    then_I_should_see_the_previously_set_configuration('5')
    and_I_set_the_input_value('3')
    click_button(I18n.t('dialogs.component_validations.button'))

    click_button(I18n.t('actions.save'))
    when_I_want_to_select_question_properties
    and_I_select_a_validation(I18n.t('question.menu.min_string_length'))
    then_I_should_see_the_previously_set_configuration('3')
    click_button(I18n.t('dialogs.button_cancel'))

    and_I_return_to_flow_page
    preview = when_I_preview_the_page('Text')
    then_I_should_preview_the_page(
      preview: preview,
      field: 'answers[text_text_1]',
      first_value: 'Po',
      second_value: 'Akira',
      error_message: "Your answer for 'Text' is too short (3 characters at least)"
    )
  end

  scenario 'max length (characters)' do
    and_I_visit_a_page('Text')
    when_I_want_to_select_question_properties
    then_I_should_see_the_string_length_validations

    and_I_select_a_validation(I18n.t('question.menu.max_string_length'))
    then_I_should_see_the_validation_modal(
      I18n.t('dialogs.component_validations.string.max.label'),
      I18n.t('dialogs.component_validations.string.max.status_label')
    )

    and_I_enable_the_validation
    click_button(I18n.t('dialogs.component_validations.button'))
    then_I_should_see_an_error_message(
      I18n.t(
      'activemodel.errors.models.base_component_validation.blank',
      label: I18n.t('dialogs.component_validations.string.max.label')
    ))

    and_I_set_the_input_value('20')
    click_button(I18n.t('dialogs.component_validations.button'))
    then_I_should_not_see_the_validation_modal(
      I18n.t('dialogs.component_validations.string.max.label'),
      I18n.t('dialogs.component_validations.string.max.status_label')
    )

    when_I_want_to_select_question_properties
    and_I_select_a_validation(I18n.t('question.menu.max_string_length'))
    then_I_should_see_the_previously_set_configuration('20')
    and_I_set_the_input_value('10')
    click_button(I18n.t('dialogs.component_validations.button'))

    click_button(I18n.t('actions.save'))
    when_I_want_to_select_question_properties
    and_I_select_a_validation(I18n.t('question.menu.max_string_length'))
    then_I_should_see_the_previously_set_configuration('10')
    click_button(I18n.t('dialogs.button_cancel'))

    and_I_return_to_flow_page
    preview = when_I_preview_the_page('Text')
    then_I_should_preview_the_page(
      preview: preview,
      field: 'answers[text_text_1]',
      first_value: 'Wolfeschlegelshteinhausenbergerdorff',
      second_value: 'Bob',
      error_message: "Your answer for 'Text' is too long (10 characters at most)"
    )
  end

  scenario 'min word' do
    and_I_visit_a_page('Textarea')
    when_I_want_to_select_question_properties
    then_I_should_see_the_string_length_validations

    and_I_select_a_validation(I18n.t('question.menu.min_string_length'))
    then_I_should_see_the_validation_modal(
      I18n.t('dialogs.component_validations.string.min.label'),
      I18n.t('dialogs.component_validations.string.min.status_label')
    )

    and_I_enable_the_validation
    and_I_select_the_radio('Words')
    click_button(I18n.t('dialogs.component_validations.button'))
    then_I_should_see_an_error_message(
      I18n.t(
      'activemodel.errors.models.base_component_validation.blank',
      label: I18n.t('dialogs.component_validations.string.min.label')
    ))
    then_the_radio_is_selected('Words')

    and_I_set_the_input_value('10')
    click_button(I18n.t('dialogs.component_validations.button'))
    then_I_should_not_see_the_validation_modal(
      I18n.t('dialogs.component_validations.string.min.label'),
      I18n.t('dialogs.component_validations.string.min.status_label')
    )

    when_I_want_to_select_question_properties
    and_I_select_a_validation(I18n.t('question.menu.min_string_length'))
    then_I_should_see_the_previously_set_configuration('10')
    and_I_set_the_input_value('5')
    click_button(I18n.t('dialogs.component_validations.button'))

    click_button(I18n.t('actions.save'))
    when_I_want_to_select_question_properties
    and_I_select_a_validation(I18n.t('question.menu.min_string_length'))
    then_I_should_see_the_previously_set_configuration('5')
    then_the_radio_is_selected('Words')
    click_button(I18n.t('dialogs.button_cancel'))

    and_I_return_to_flow_page
    preview = when_I_preview_the_page('Textarea')
    then_I_should_preview_the_page(
      preview: preview,
      field: 'answers[textarea_textarea_1]',
      first_value: 'Once upon a time',
      second_value: "Mother died today. Or, maybe, yesterday; I can't be sure",
      error_message: "Enter a higher number of words for Textarea"
    )
  end

  scenario 'max word' do
    and_I_visit_a_page('Textarea')
    when_I_want_to_select_question_properties
    then_I_should_see_the_string_length_validations

    and_I_select_a_validation(I18n.t('question.menu.max_string_length'))
    then_I_should_see_the_validation_modal(
      I18n.t('dialogs.component_validations.string.max.label'),
      I18n.t('dialogs.component_validations.string.max.status_label')
    )

    and_I_enable_the_validation
    and_I_select_the_radio('Words')
    click_button(I18n.t('dialogs.component_validations.button'))
    then_I_should_see_an_error_message(
      I18n.t(
      'activemodel.errors.models.base_component_validation.blank',
      label: I18n.t('dialogs.component_validations.string.max.label')
    ))
    then_the_radio_is_selected('Words')

    and_I_set_the_input_value('50')
    click_button(I18n.t('dialogs.component_validations.button'))
    then_I_should_not_see_the_validation_modal(
      I18n.t('dialogs.component_validations.string.max.label'),
      I18n.t('dialogs.component_validations.string.max.status_label')
    )

    when_I_want_to_select_question_properties
    and_I_select_a_validation(I18n.t('question.menu.max_string_length'))
    then_I_should_see_the_previously_set_configuration('50')
    and_I_set_the_input_value('20')
    click_button(I18n.t('dialogs.component_validations.button'))

    click_button(I18n.t('actions.save'))
    when_I_want_to_select_question_properties
    and_I_select_a_validation(I18n.t('question.menu.max_string_length'))
    then_I_should_see_the_previously_set_configuration('20')
    then_the_radio_is_selected('Words')
    click_button(I18n.t('dialogs.button_cancel'))

    and_I_return_to_flow_page
    preview = when_I_preview_the_page('Textarea')
    then_I_should_preview_the_page(
      preview: preview,
      field: 'answers[textarea_textarea_1]',
      first_value: 'The story so far: in the beginning, the universe was created. This has made a lot of people very angry and been widely regarded as a bad move.',
      second_value: 'All this happened, more or less.',
      error_message: "Enter a lower number of words for Textarea"
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
    page.find(:css, 'input#component_validation_value').set('')
    page.find(:css, 'input#component_validation_value').set(value)
  end

  def and_I_select_the_radio(text)
    choose(text, visible: false)
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
    expect(page).to have_content(I18n.t('question.menu.minimum'))
    expect(page).to have_content(I18n.t('question.menu.maximum'))
  end

  def then_I_should_see_the_validation_modal(label, status_label)
    expect(page).to have_content(label)
    expect(page).to have_content(status_label)
  end

  def then_I_should_see_an_error_message(error_message)
    expect(page).to have_content(error_message)
  end

  def then_I_should_not_see_an_error_message(error_message)
    expect(page).to_not have_content(error_message)
  end

  def then_I_should_not_see_the_validation_modal(label, status_label)
    expect(page).to_not have_content(label)
    expect(page).to_not have_content(status_label)
  end

  def then_I_should_see_the_previously_set_configuration(value)
    input = page.find(:css, 'input#component_validation_value')
    expect(input.value).to eq(value)
  end

  def then_I_should_preview_the_page(preview:, field:, first_value:, second_value:, error_message:)
    within_window(preview) do
      page.find_field(field).set(first_value)
      click_button(I18n.t('actions.continue'))
      then_I_should_see_an_error_message(error_message)
      page.find_field(field).set(second_value)
      click_button(I18n.t('actions.continue'))
      then_I_should_not_see_an_error_message(error_message)
    end
  end

  def then_I_should_see_the_date_before_and_after_validations
    expect(page).to have_content(I18n.t('question.menu.date_before'))
    expect(page).to have_content(I18n.t('question.menu.date_after'))
  end

  def then_I_should_see_the_previously_set_date_configuration(field, value)
    input = page.find_field("component_validation[#{field}]")
    expect(input.value).to eq(value)
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

  def then_I_should_see_the_string_length_validations
    expect(page).to have_content(I18n.t('question.menu.max_string_length'))
    expect(page).to have_content(I18n.t('question.menu.min_string_length'))
  end

  def then_the_radio_is_selected(text)
    sleep(1)
    expect(page.find("#component_validation_#{text.downcase}", visible: false)).to be_selected
    # page.find("#component_validation_#{text.downcase}", visible: false).selected?
  end
end
