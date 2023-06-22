require_relative '../spec_helper'

feature 'Create a service' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:another_service_name) { generate_service_name }
  let(:start_page_title) { 'Service name goes here' }
  let(:checkanswers_link_text) { I18n.t('actions.add_check_answers') }
  let(:checkanswers_title) { 'Check your answers' }
  let(:confirmation_link_text) { I18n.t('actions.add_confirmation')  }
  let(:confirmation_title) { 'Application complete' }
  let(:exit_link_text) { I18n.t('actions.add_exit')  }
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
    then_I_should_not_be_able_to_add_page(start_page_title, checkanswers_link_text)
    then_I_should_not_be_able_to_add_page(start_page_title, confirmation_link_text)
    then_I_should_not_be_able_to_add_page(start_page_title, exit_link_text)
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
    then_I_should_not_be_able_to_add_page(start_page_title, checkanswers_link_text)
    then_I_should_not_be_able_to_add_page(start_page_title, confirmation_link_text)
    and_I_add_a_content_page('Content Page')
    given_I_add_an_exit_page
    and_I_return_to_flow_page
    then_some_pages_should_be_unconnected
    then_I_should_not_be_able_to_add_page(start_page_title, checkanswers_link_text)
    then_I_should_not_be_able_to_add_page(start_page_title, confirmation_link_text)
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
    expect(editor).to have_content(
      I18n.t('activemodel.errors.messages.blank', attribute: 'Give your form a name')
    )
  end

  def then_I_should_see_a_validation_message_for_min_length
    expect(editor).to have_content(
      I18n.t('activemodel.errors.messages.too_short', attribute: 'Give your form a name', count: Editor::Service::MINIMUM)
    )
  end

  def then_I_should_see_a_validation_message_for_max_length
    expect(editor).to have_content(
      I18n.t('activemodel.errors.messages.too_long', attribute: 'Give your form a name', count: Editor::Service::MAXIMUM)
    )
  end

  def then_I_should_see_the_unique_validation_message
    expect(editor).to have_content(
      I18n.t('activemodel.errors.messages.taken', attribute: 'Give your form a name')
    )
  end

  def given_I_have_an_exit_page
    given_I_add_an_exit_page
    and_I_add_a_page_url(exit_url)
    when_I_add_the_page
  end

  def then_some_pages_should_be_unconnected
    expect(editor.unconnected_flow).to eq(
      [
        'Check your answers',
        'Application complete'
      ]
    )
  end
end
