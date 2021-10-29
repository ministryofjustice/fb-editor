require_relative '../spec_helper'

feature 'Edit exit pages' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:exit_url) { 'exit' }
  let(:exit_heading) { 'Updated heading' }
  let(:exit_section_heading) { 'Updated section heading' }
  let(:exit_lede) { 'Updated lede' }
  let(:content_component) do
    'Give me content'
  end
  let(:optional_content) do
    I18n.t('default_text.content')
  end
  let(:default_exit_page_title) { 'Title' }

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'updates all fields' do
    given_I_have_an_exit_page
    then_I_should_not_see_the_continue_button
    and_I_change_the_page_heading(exit_heading)
    and_I_change_the_page_section_heading(exit_section_heading)
    and_I_change_the_page_lede(exit_lede)
    when_I_save_my_changes
    and_I_return_to_flow_page
    and_I_click_on_the_three_dots
    then_I_should_only_see_three_options_on_page_menu
    and_I_edit_the_page(url: exit_heading)
    then_I_see_the_updated_page_heading(exit_heading)
    then_I_see_the_updated_page_section_heading(exit_section_heading)
    then_I_see_the_updated_page_lede(exit_lede)
  end

  scenario 'adding components' do
    given_I_have_an_exit_page
    then_I_should_not_see_the_continue_button
    and_I_add_a_content_component(
      content: content_component
    )
    when_I_save_my_changes
    and_I_return_to_flow_page
    and_I_edit_the_page(url: default_exit_page_title)
    then_I_should_see_the_component(content_component)
  end

  scenario 'deleting components' do
    given_I_have_an_exit_page
    then_I_should_not_see_the_continue_button
    and_I_add_a_content_component(
      content: content_component
    )
    when_I_save_my_changes
    and_I_return_to_flow_page
    and_I_edit_the_page(url: default_exit_page_title)
    then_I_should_see_the_component(content_component)
    when_I_want_to_select_component_properties('.output', content_component)
    and_I_want_to_delete_a_component
    then_I_should_not_see_my_content(content_component)
  end

  def given_I_have_an_exit_page
    given_I_add_an_exit_page
    and_I_add_a_page_url(exit_url)
    when_I_add_the_page
  end

  def and_I_add_a_content_component(content:)
    editor.add_content_area_buttons.first.click
    and_the_content_component_has_the_optional_content
    when_I_change_editable_content(editor.first_component, content: content)
  end

  def then_I_should_see_the_component(content)
    expect(editor.first_component.text).to eq(content)
  end

  def then_I_should_not_see_the_continue_button
    expect(page).not_to have_content(I18n.t('actions.continue'))
  end

  def and_the_content_component_has_the_optional_content
    editor.service_name.click # click outside to close the editable component

    # the output element p tag of a content component is the thing which has
    # the actual text in it
    output_component = editor.first_component.find('.output p', visible: false)
    expect(output_component.text).to eq(optional_content)
  end
end
