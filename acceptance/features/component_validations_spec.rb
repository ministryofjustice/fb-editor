require_relative '../spec_helper'

feature 'Component validations' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:fixture) { 'all_component_types_fixture' }

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(name: service_name, fixture: fixture)
  end


  shared_examples 'a number component validation' do
    scenario 'configuring number validation' do
      and_I_visit_a_page(page_url)
      when_I_want_to_select_question_properties
      then_I_should_see_the_minimum_and_maximum_validations

      and_I_select_a_validation(menu_text)
      then_I_should_see_the_validation_modal(label, status_label)

      and_I_enable_the_validation
      click_button(I18n.t('dialogs.component_validations.button'))
      then_I_should_see_an_error_message(
        I18n.t(
        'activemodel.errors.models.base_component_validation.blank',
        label: label
      ))

      and_I_set_the_input_value(first_value)
      click_button(I18n.t('dialogs.component_validations.button'))
      then_I_should_not_see_the_validation_modal(label, status_label)

      when_I_want_to_select_question_properties
      and_I_select_a_validation(menu_text)
      then_I_should_see_the_previously_set_configuration(first_value)
      and_I_set_the_input_value(second_value)
      click_button(I18n.t('dialogs.component_validations.button'))

      and_I_click_save
      when_I_want_to_select_question_properties
      and_I_select_a_validation(menu_text)
      then_I_should_see_the_previously_set_configuration(second_value)
      click_button(I18n.t('dialogs.button_cancel'))

      and_I_return_to_flow_page
      preview = when_I_preview_the_page(page_url)
      then_I_should_preview_the_page(
        preview: preview,
        field: preview_field,
        first_value: preview_first_value,
        second_value: preview_second_value,
        error_message: preview_error_message
      )
    end
  end

  shared_examples 'a date component validation' do
    scenario 'configuring date validation' do
      and_I_visit_a_page(page_url)
      when_I_want_to_select_question_properties
      then_I_should_see_the_date_before_and_after_validations

      and_I_select_a_validation(menu_text)
      then_I_should_see_the_validation_modal(label, status_label)

      and_I_enable_the_validation
      first_answers.each do |field, value|
        and_I_set_the_date_input_value(field, value)
      end
      click_button(I18n.t('dialogs.component_validations.button'))
      then_I_should_see_an_error_message(
        I18n.t(
        'activemodel.errors.models.date_validation.missing_attribute',
        label: error_message_label,
        attribute: error_message_attribute
      ))

      and_I_set_the_date_input_value(invalid_field_answer['field'], invalid_field_answer['invalid'])
      click_button(I18n.t('dialogs.component_validations.button'))
      then_I_should_see_an_error_message(
        I18n.t(
        'activemodel.errors.models.date_validation.invalid',
        label: label
      ))

      and_I_set_the_date_input_value(invalid_field_answer['field'], invalid_field_answer['valid'])
      click_button(I18n.t('dialogs.component_validations.button'))
      then_I_should_not_see_the_validation_modal(label, status_label)

      when_I_want_to_select_question_properties
      and_I_select_a_validation(menu_text)
      first_answers.each do |field, value|
        then_I_should_see_the_previously_set_date_configuration(field, value)
      end
      then_I_should_see_the_previously_set_date_configuration(invalid_field_answer['field'], invalid_field_answer['valid'])

      second_answers.each do |field, value|
        and_I_set_the_date_input_value(field, value)
      end
      click_button(I18n.t('dialogs.component_validations.button'))

      and_I_click_save
      when_I_want_to_select_question_properties
      and_I_select_a_validation(menu_text)
      second_answers.each do |field, value|
        then_I_should_see_the_previously_set_date_configuration(field, value)
      end
      click_button(I18n.t('dialogs.button_cancel'))

      and_I_return_to_flow_page
      preview = when_I_preview_the_page(page_url)
      then_I_should_preview_the_date_page(
        preview: preview,
        first_date: preview_first_date,
        second_date: preview_second_date,
        error_message: preview_error_message
      )
    end
  end

  shared_examples 'a string length characters validation' do
    scenario 'configuring string length characters validation' do
      and_I_visit_a_page(page_url)
      when_I_want_to_select_question_properties
      then_I_should_see_the_string_length_validations

      and_I_select_a_validation(menu_text)
      then_I_should_see_the_validation_modal(label, status_label)

      and_I_enable_the_validation
      then_the_radio_is_selected('Characters')
      click_button(I18n.t('dialogs.component_validations.button'))
      then_I_should_see_an_error_message(
        I18n.t(
        'activemodel.errors.models.base_component_validation.blank',
        label: label
      ))

      and_I_set_the_input_value(first_answer)
      click_button(I18n.t('dialogs.component_validations.button'))
      then_I_should_not_see_the_validation_modal(label, status_label)

      when_I_want_to_select_question_properties
      and_I_select_a_validation(menu_text)
      then_I_should_see_the_previously_set_configuration(first_answer)
      then_the_radio_is_selected('Characters')
      and_I_set_the_input_value(second_answer)
      click_button(I18n.t('dialogs.component_validations.button'))

      and_I_click_save
      when_I_want_to_select_question_properties
      and_I_select_a_validation(menu_text)
      then_I_should_see_the_previously_set_configuration(second_answer)
      click_button(I18n.t('dialogs.button_cancel'))
      
      sleep(0.5)
      when_I_want_to_select_question_properties
      and_I_select_a_validation(menu_text)
      then_the_radio_is_selected('Characters')
      and_I_set_the_input_value('')
      and_I_select_the_radio('Words')
      click_button(I18n.t('dialogs.component_validations.button'))
      then_I_should_see_an_error_message(
        I18n.t(
        'activemodel.errors.models.base_component_validation.blank',
        label: label
      ))
      then_the_radio_is_selected('Words')
      click_button(I18n.t('dialogs.button_cancel'))

      when_I_want_to_select_question_properties
      and_I_select_a_validation(alt_menu_text)
      then_the_radio_is_selected('Characters')
      click_button(I18n.t('dialogs.button_cancel'))

      and_I_return_to_flow_page
      preview = when_I_preview_the_page(page_url)
      then_I_should_preview_the_page(
        preview: preview,
        field: preview_field,
        first_value: preview_first_answer,
        second_value: prview_second_answer,
        error_message: preview_error_message
      )
    end
  end

  shared_examples 'a string length words validation' do
    scenario 'configuring string length words validation' do
      and_I_visit_a_page(page_url)
      when_I_want_to_select_question_properties
      then_I_should_see_the_string_length_validations

      and_I_select_a_validation(menu_text)
      then_I_should_see_the_validation_modal(label, status_label)

      and_I_enable_the_validation
      and_I_select_the_radio('Words')
      click_button(I18n.t('dialogs.component_validations.button'))
      then_I_should_see_an_error_message(
        I18n.t(
        'activemodel.errors.models.base_component_validation.blank',
        label: label
      ))
      then_the_radio_is_selected('Words')

      and_I_set_the_input_value(first_answer)
      click_button(I18n.t('dialogs.component_validations.button'))
      then_I_should_not_see_the_validation_modal(label, status_label)

      when_I_want_to_select_question_properties
      and_I_select_a_validation(menu_text)
      then_I_should_see_the_previously_set_configuration(first_answer)
      then_the_radio_is_selected('Words')
      and_I_set_the_input_value(second_answer)
      click_button(I18n.t('dialogs.component_validations.button'))

      and_I_click_save
      when_I_want_to_select_question_properties
      and_I_select_a_validation(menu_text)
      then_I_should_see_the_previously_set_configuration(second_answer)
      then_the_radio_is_selected('Words')
      click_button(I18n.t('dialogs.button_cancel'))
      
      sleep(0.5)
      when_I_want_to_select_question_properties
      and_I_select_a_validation(menu_text)
      then_the_radio_is_selected('Words')
      and_I_set_the_input_value('')
      and_I_select_the_radio('Characters')
      click_button(I18n.t('dialogs.component_validations.button'))
      then_I_should_see_an_error_message(
        I18n.t(
        'activemodel.errors.models.base_component_validation.blank',
        label: label
      ))
      then_the_radio_is_selected('Characters')
      click_button(I18n.t('dialogs.button_cancel'))

      when_I_want_to_select_question_properties
      and_I_select_a_validation(alt_menu_text)
      then_the_radio_is_selected('Characters')
      click_button(I18n.t('dialogs.button_cancel'))

      and_I_return_to_flow_page
      preview = when_I_preview_the_page('Textarea')
      then_I_should_preview_the_page(
        preview: preview,
        field: preview_field,
        first_value: preview_first_answer,
        second_value: preview_second_answer,
        error_message: preview_error_message
      )
    end
  end

  context 'minimum validation' do
    let(:page_url) { 'Number' }
    let(:menu_text) { I18n.t('question.menu.minimum') }
    let(:label) { I18n.t('dialogs.component_validations.minimum.label') }
    let(:status_label) { I18n.t('dialogs.component_validations.minimum.status_label') }
    let(:first_value) { '5' }
    let(:second_value) { '3' }
    let(:preview_field) { 'answers[number_number_1]' }
    let(:preview_first_value) { '1' }
    let(:preview_second_value) { '20' }
    let(:preview_error_message) { 'Your answer for "Number" must be 3 or higher' }

    it_behaves_like 'a number component validation'
  end

  context 'maximum validation' do
    let(:page_url) { 'Number' }
    let(:menu_text) { I18n.t('question.menu.maximum') }
    let(:label) { I18n.t('dialogs.component_validations.maximum.label') }
    let(:status_label) { I18n.t('dialogs.component_validations.maximum.status_label') }
    let(:first_value) { '100' }
    let(:second_value) { '50' }
    let(:preview_field) { 'answers[number_number_1]' }
    let(:preview_first_value) { '100' }
    let(:preview_second_value) { '5' }
    let(:preview_error_message) { 'Your answer for "Number" must be 50 or lower' }

    it_behaves_like 'a number component validation'
  end

  context 'date after validation' do
    let(:page_url) { 'Date' }
    let(:menu_text) { I18n.t('question.menu.date_after') }
    let(:label) { I18n.t('dialogs.component_validations.date_after.label') }
    let(:status_label) { I18n.t('dialogs.component_validations.date_after.status_label') }
    let(:first_answers) { { 'day' => '10', 'month' => '11' } }
    let(:invalid_field_answer) do
      {
        'field' => 'year',
        'invalid' => 'this is not a year' ,
        'valid' => '2001'
      }
    end
    let(:error_message_label) { 'Earliest date'}
    let(:error_message_attribute) { I18n.t('dialogs.component_validations.date.year').downcase }
    let(:second_answers) { { 'day' => '28', 'month' => '02', 'year' => '1999' } }
    let(:preview_first_date) { { day: '01', month: '02', year: '1901' } }
    let(:preview_second_date) { { day: '28', month: '02', year: '2001' } }
    let(:preview_error_message) { 'Your answer for "Date" must be 28 02 1999 or later' }

    it_behaves_like 'a date component validation'
  end

  context 'date before validation' do
    let(:page_url) { 'Date' }
    let(:menu_text) { I18n.t('question.menu.date_before') }
    let(:label) { I18n.t('dialogs.component_validations.date_before.label') }
    let(:status_label) { I18n.t('dialogs.component_validations.date_before.status_label') }
    let(:first_answers) { { 'month' => '06', 'year' => '2050' } }
    let(:invalid_field_answer) do
      {
        'field' => 'day',
        'invalid' => 'this is not a day' ,
        'valid' => '30'
      }
    end
    let(:error_message_label) { 'Latest date'}
    let(:error_message_attribute) { I18n.t('dialogs.component_validations.date.day').downcase }
    let(:second_answers) { { 'day' => '14', 'month' => '08', 'year' => '2045' } }
    let(:preview_first_date) { { day: '01', month: '02', year: '2050' } }
    let(:preview_second_date) { { day: '28', month: '02', year: '2001' } }
    let(:preview_error_message) { 'Your answer for "Date" must be 14 08 2045 or earlier' }

    it_behaves_like 'a date component validation'
  end

  context 'min length (characters)' do
    let(:page_url) { 'Text' }
    let(:menu_text) { I18n.t('question.menu.min_string_length') }
    let(:alt_menu_text) { I18n.t('question.menu.max_string_length') }
    let(:label) { I18n.t('dialogs.component_validations.string.min.label') }
    let(:status_label) { I18n.t('dialogs.component_validations.string.min.status_label') }
    let(:first_answer) { '5' }
    let(:second_answer) { '3' }
    let(:preview_field) { 'answers[text_text_1]' }
    let(:preview_first_answer) { 'Po' }
    let(:prview_second_answer) { 'Akira' }
    let(:preview_error_message) { 'Your answer for "Text" must be 3 characters or more' }

    it_behaves_like 'a string length characters validation'
  end

  context 'max length (characters)' do
    let(:page_url) { 'Text' }
    let(:menu_text) { I18n.t('question.menu.max_string_length') }
    let(:alt_menu_text) { I18n.t('question.menu.min_string_length') }
    let(:label) { I18n.t('dialogs.component_validations.string.max.label') }
    let(:status_label) { I18n.t('dialogs.component_validations.string.max.status_label') }
    let(:first_answer) { '20' }
    let(:second_answer) { '10' }
    let(:preview_field) { 'answers[text_text_1]' }
    let(:preview_first_answer) { 'Wolfeschlegelshteinhausenbergerdorff' }
    let(:prview_second_answer) { 'Bob' }
    let(:preview_error_message) { 'Your answer for "Text" must be 10 characters or fewer' }

    it_behaves_like 'a string length characters validation'
  end

  context 'min word' do
    let(:page_url) { 'Textarea' }
    let(:menu_text) { I18n.t('question.menu.min_string_length') }
    let(:alt_menu_text) { I18n.t('question.menu.max_string_length') }
    let(:label) { I18n.t('dialogs.component_validations.string.min.label') }
    let(:status_label) { I18n.t('dialogs.component_validations.string.min.status_label') }
    let(:first_answer) { '20' }
    let(:second_answer) { '10' }
    let(:preview_field) { 'answers[textarea_textarea_1]' }
    let(:preview_first_answer) { 'Mother died today.' }
    let(:preview_second_answer) do
      'He was an old man who fished alone in a skiff in the Gulf Stream and he had gone eighty-four days now without taking a fish.'
    end
    let(:preview_error_message) { 'Your answer for "Textarea" must be 10 words or more' }

    it_behaves_like 'a string length words validation'
  end

  context 'max word' do
    let(:page_url) { 'Textarea' }
    let(:menu_text) { I18n.t('question.menu.max_string_length') }
    let(:alt_menu_text) { I18n.t('question.menu.min_string_length') }
    let(:label) { I18n.t('dialogs.component_validations.string.max.label') }
    let(:status_label) { I18n.t('dialogs.component_validations.string.max.status_label') }
    let(:first_answer) { '50' }
    let(:second_answer) { '20' }
    let(:preview_field) { 'answers[textarea_textarea_1]' }
    let(:preview_first_answer) do
      'The story so far: in the beginning, the universe was created. This has made a lot of people very angry and been widely regarded as a bad move.'
    end
    let(:preview_second_answer) { 'All this happened, more or less.' }
    let(:preview_error_message) { 'Your answer for "Textarea" must be 20 words or fewer' }

    it_behaves_like 'a string length words validation'
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
    sleep(0.5)
    input_element = page.find(:css, 'input#component_validation_value')
    input_element.set(value)
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
      page.find(:css, '#main-content', visible: true)
      page.find_field(field).set(first_value)
      click_button(I18n.t('actions.continue'))
      page.find(:css, '#main-content', visible: true)
      then_I_should_see_an_error_message(error_message)

      page.find_field(field).set(second_value)
      click_button(I18n.t('actions.continue'))
      page.find(:css, '#main-content', visible: true)
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
      page.find(:css, '#main-content', visible: true)
      page.fill_in('answers[date_date_1(3i)]', with: first_date[:day])
      page.fill_in('answers[date_date_1(2i)]', with: first_date[:month])
      page.fill_in('answers[date_date_1(1i)]', with: first_date[:year])
      click_button(I18n.t('actions.continue'))
      page.find(:css, '#main-content', visible: true)
      then_I_should_see_an_error_message(error_message)

      page.fill_in('answers[date_date_1(3i)]', with: second_date[:day])
      page.fill_in('answers[date_date_1(2i)]', with: second_date[:month])
      page.fill_in('answers[date_date_1(1i)]', with: second_date[:year])
      click_button(I18n.t('actions.continue'))
      page.find(:css, '#main-content', visible: true)
      then_I_should_not_see_an_error_message(error_message)
    end
  end

  def then_I_should_see_the_string_length_validations
    expect(page).to have_content(I18n.t('question.menu.max_string_length'))
    expect(page).to have_content(I18n.t('question.menu.min_string_length'))
  end

  def then_the_radio_is_selected(text)
    expect(page.find("#component_validation_#{text.downcase}", visible: false)).to be_selected
  end

  def and_I_click_save
    sleep(1)
    click_button(I18n.t('actions.save'))
  end
end
