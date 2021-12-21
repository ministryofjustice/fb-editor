require_relative '../spec_helper'

feature 'Create a service' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:another_service_name) { generate_service_name }
  let(:checkanswers) { 'Check answers page' }
  let(:confirmation) { 'Confirmation page' }
  let(:add_page) { 'Add page here' }
  let(:exit_url) { 'exit' }
  let(:form_urls) do
    # page url links have the word "Edit" as a visually hidden span element
    # associated with them for added accessibility
    [
      "Edit:\nService name goes here",
      "Edit:\nCheck your answers",
      "Edit:\nApplication complete"
    ]
  end

  background do
    given_I_am_logged_in
    given_I_want_to_create_a_service
  end

  scenario 'validates the service name' do
    given_I_add_a_service_with_empty_name
    when_I_create_the_service
    then_I_should_see_a_validation_message_for_required
  end

  scenario 'validates the service name min length' do
    given_I_add_a_service_with_one_character
    when_I_create_the_service
    then_I_should_see_a_validation_message_for_min_length
  end

  scenario 'validates the service name max length' do
    given_I_add_a_service_with_many_characters
    when_I_create_the_service
    then_I_should_see_a_validation_message_for_max_length
  end

  scenario 'creates the service with default pages' do
    given_I_add_a_service
    when_I_create_the_service
    then_I_should_see_the_new_service_name
    then_I_should_see_default_service_pages
    then_I_should_see_the_page_flow_in_order(order: form_urls)
    then_I_should_not_be_able_to_add_page(checkanswers)
    then_I_should_not_be_able_to_add_page(confirmation)
    when_I_three_dots_button_on_the_confirmation_page
    then_I_should_not_be_able_to_see_add_page_link
  end

  scenario 'validates uniqueness of the service name' do
    given_I_have_a_service
    when_I_try_to_create_a_service_with_the_same_name
    then_I_should_see_the_unique_validation_message
  end

  scenario 'prevent duplicate checkanswers and confirmation in a service' do
    given_I_add_a_service
    when_I_create_the_service
    then_I_should_see_default_service_pages
    then_I_should_not_be_able_to_add_page(checkanswers)
    then_I_should_not_be_able_to_add_page(confirmation)
    given_I_add_an_exit_page
    and_I_return_to_flow_page
    then_some_pages_should_be_unconnected
    then_I_should_not_be_able_to_add_page(checkanswers)
    then_I_should_not_be_able_to_add_page(confirmation)
  end

  def given_I_add_a_service_with_empty_name
    editor.name_field.set('')
  end

  def given_I_add_a_service_with_one_character
    editor.name_field.set('M')
  end

  def given_I_add_a_service_with_many_characters
    editor.name_field.set('Stormtroopers' * 100)
  end

  def then_I_should_see_the_new_service_name
    expect(editor.service_name.text).to eq(service_name)
  end

  def then_I_should_see_a_validation_message_for_required
    expect(editor.text).to include(
      I18n.t('activemodel.errors.messages.blank', attribute: 'Give your form a name')
    )
  end

  def then_I_should_see_a_validation_message_for_min_length
    expect(editor.text).to include(
      I18n.t('activemodel.errors.messages.too_short', attribute: 'Give your form a name', count: '3')
    )
  end

  def then_I_should_see_a_validation_message_for_max_length
    expect(editor.text).to include(
      I18n.t('activemodel.errors.messages.too_long', attribute: 'Give your form a name', count: '128')
    )
  end

  def then_I_should_see_the_unique_validation_message
    expect(editor.text).to include(
      I18n.t('activemodel.errors.messages.taken', attribute: 'Give your form a name')
    )
  end

  def given_I_have_an_exit_page
    given_I_add_an_exit_page
    and_I_add_a_page_url(exit_url)
    when_I_add_the_page
  end

  def then_some_pages_should_be_unconnected
    editor.unconnected_expand_link.click
    expect(editor.unconnected_flow).to eq(
      [
        'Check your answers',
        'Application complete'
      ]
    )
  end

  def when_I_three_dots_button_on_the_confirmation_page
    sleep 0.5 # Arbitrary delay, possibly required due to focus issues
    page.find('.govuk-link', text: 'Application complete').hover
    editor.three_dots_button.click
  end

  def then_I_should_not_be_able_to_see_add_page_link
    expect(editor.text).not_to include(add_page)
  end
end
