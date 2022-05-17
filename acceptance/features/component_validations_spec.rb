require_relative '../spec_helper'

feature 'Move a page' do
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

  def then_I_should_not_see_the_validation_modal(label, status_label)
    sleep(1)
    expect(page.text).to_not include(label)
    expect(page.text).to_not include(status_label)
  end

  def then_I_should_see_the_previously_set_configuration(value)
    expect(page.find(:css, 'input#component_validation_value').value).to eq(value)
  end
end
