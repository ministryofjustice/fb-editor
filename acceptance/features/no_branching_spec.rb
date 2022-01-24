require_relative '../spec_helper'

feature 'No branching' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }

  background do
    given_I_am_logged_in
    given_I_want_to_create_a_service
  end

  scenario 'the editor works without the branching feature flag set' do
    given_I_add_a_service
    when_I_create_the_service
    then_I_should_see_the_new_service_name
    then_I_should_see_the_add_page_button
    then_I_should_not_see_the_cya_and_confirmation_pages
    then_I_should_not_see_the_unconnected_section

    then_I_should_not_see_the_change_destination_link
    then_I_should_not_see_the_add_branching_link
    then_I_should_not_see_the_add_exit_page_link
  end

  def then_I_should_see_the_new_service_name
    expect(editor.service_name.text).to eq(service_name)
  end

  def then_I_should_see_the_add_page_button
    expect(page.text).to include(I18n.t('pages.create'))
  end

  def then_I_should_not_see_the_cya_and_confirmation_pages
    expect(page.text).not_to include('Check your answers')
    expect(page.text).not_to include('Application complete')
  end

  def then_I_should_not_see_the_unconnected_section
    expect(page.text).not_to include('Unconnected')
  end

  def then_I_should_not_see_the_change_destination_link
    editor.hover_preview('Service name goes here')
    editor.three_dots_button.click
    expect(page.text).not_to include(I18n.t('actions.change_destination'))
  end

  def then_I_should_not_see_the_add_branching_link
    editor.hover_preview('Service name goes here')
    editor.three_dots_button.click
    expect(page.text).not_to include(I18n.t('actions.add_branch'))
  end

  def then_I_should_not_see_the_add_exit_page_link
    editor.hover_preview('Service name goes here')
    editor.three_dots_button.click
    expect(page.text).not_to include(I18n.t('page.exit'))
  end
end
