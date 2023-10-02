require_relative '../spec_helper'

feature 'Conditional content' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:fixture) { 'conditional_content_fixture' }
  let(:optional_content) do
    I18n.t('default_text.content')
  end

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(fixture: fixture)
  end

  context 'adding conditonal content' do
    
    scenario 'to start page' do
      and_I_edit_the_page(url: 'Service name goes here')
      when_I_focus_editable_content(editor.page_body)
      then_I_should_not_see_the_conditional_content_menu_option
      when_I_focus_editable_content(editor.page_before_you_start)
      then_I_should_not_see_the_conditional_content_menu_option
    end

    scenario 'to multiple question page' do
      Rails.logger.info "CONDITIONAL CONTENT:: #{ENV['CONDITIONAL_CONTENT']}"
      and_I_edit_the_page(url: 'Multiple') 
      and_I_add_a_multiple_page_content_component
      when_I_want_to_edit_content_component_properties(editor.editable_content_areas.last)
      then_I_should_see_the_conditional_content_menu_option
      and_I_want_to_set_content_visibility
then_I_should_see_the_conditional_content_modal
    end

    scenario 'to content pages' do
      and_I_edit_the_page(url: 'Conditional content')
      and_I_add_a_content_component(content: 'You will always see this content')
      when_I_want_to_edit_content_component_properties(editor.editable_content_areas.last)
      then_I_should_see_the_conditional_content_menu_option
      and_I_want_to_set_content_visibility
then_I_should_see_the_conditional_content_modal
    end

    scenario 'to exit pages' do
      and_I_edit_the_page(url: 'Bye')
      when_I_want_to_edit_content_component_properties(editor.editable_content_areas.last)
      then_I_should_see_the_conditional_content_menu_option
and_I_want_to_set_content_visibility
then_I_should_see_the_conditional_content_modal
    end

    scenario 'to check your answers pages' do
      and_I_edit_the_page(url: 'Check your answers')
      and_I_add_a_content_component(content: 'You will always see this content')
      when_I_want_to_edit_content_component_properties(editor.editable_content_areas.last)
      then_I_should_see_the_conditional_content_menu_option
and_I_want_to_set_content_visibility
then_I_should_see_the_conditional_content_modal
    end

    scenario 'to confirmation page' do
      and_I_edit_the_page(url: 'Application complete')
      and_I_add_a_content_component(content: 'You will always see this content')
      when_I_want_to_edit_content_component_properties(editor.editable_content_areas.last)
      then_I_should_see_the_conditional_content_menu_option
and_I_want_to_set_content_visibility
then_I_should_see_the_conditional_content_modal
    end
  end


  def then_I_should_not_see_the_conditional_content_menu_option
    expect(editor).to_not have_show_if_link
  end

  def then_I_should_see_the_conditional_content_menu_option
    expect(editor).to have_show_if_link
  end

  def and_I_want_to_set_content_visibility
    editor.show_if_link.click 
  end

  def then_I_should_see_the_conditional_content_modal
    expect(editor).to have_conditional_content_modal
  end
end
