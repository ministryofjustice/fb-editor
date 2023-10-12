require_relative '../spec_helper'

feature 'Preview conditional content' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:optional_content) { I18n.t('default_text.content') }

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(fixture: 'conditional_content_preview_fixture')
  end

  context 'exit page' do
    let(:page_title) { 'Sorry' } 
    let(:always_content) { 'This content is always visible' }
    let(:never_content) { 'This content is never visible' }
    let(:conditional_content) { 'This content is sometimes visible' }
    let(:component) { 'Do you like coffee?' }

    scenario 'previewing exit pages' do
      when_I_add_content_that_always_displays(page_title:, content: always_content)

      then_when_I_preview_the_page(page_title:) do
        expect(page).not_to have_content I18n.t('presenter.conditional_content.notification')
        expect(page).to have_content always_content
      end

      when_I_add_content_that_never_displays(page_title:, content: never_content)

      then_when_I_preview_the_page(page_title:) do
        expect(page).to have_content I18n.t('presenter.conditional_content.notification')
        expect(page).to have_content always_content
        expect(page).to have_content never_content
      end

      when_I_edit_content_to_display_conditionally(page_title:, content: conditional_content)

      then_when_I_preview_the_page(page_title:) do
        expect(page).to have_content I18n.t('presenter.conditional_content.notification')
        expect(page).to have_content always_content
        expect(page).to have_content conditional_content
      end

      when_I_add_content_that_never_displays(page_title:, content: never_content)

      preview_form = when_I_preview_the_form
      within_window(preview_form) do
        expect(page).to have_content('Service name goes here')
        page.click_button 'Start now'
        expect(page).to have_content('Do you like coffee?')
        find('label', text: 'no').click
        page.click_button 'Continue'
        expect(page).to have_content('Sorry')
        expect(page).to have_content(always_content)
        expect(page).not_to have_content(never_content)
        expect(page).to have_content(conditional_content)
        expect(page).not_to have_content I18n.t('presenter.conditional_content.notification')
      end
    end
  end




  

end

def when_I_add_content_that_always_displays(page_title:, content:)
    when_I_edit_the_page(title: page_title)
    and_I_add_a_content_component(content: content)
    when_I_save_my_changes
    and_I_return_to_flow_page 
end

def when_I_add_content_that_never_displays(page_title:, content:)
    when_I_edit_the_page(title: page_title)
    and_I_add_a_content_component(content:)
    and_I_want_to_edit_content_visibility_for(editor.last_editable_content_area)
    and_I_set_display_to_never
    when_I_update_conditional_content
    when_I_save_my_changes
    and_I_return_to_flow_page 
end

def when_I_edit_content_to_display_conditionally(page_title:,content:)
    when_I_edit_the_page(title: page_title)
    when_I_change_editable_content(editor.last_editable_content_area, content:)
    and_I_want_to_edit_content_visibility_for(editor.last_editable_content_area)
    and_I_set_display_to_conditional
    editor.conditional_content_modal.conditionals.first.within do |conditional|
        conditional.expressions.first.within do |expression| 
          when_I_select_a_component(expression, radios_question)
          and_I_select_an_operator(expression, 'is')
          and_I_select_an_answer(expression, 'no')
        end
    end
    when_I_update_conditional_content
    when_I_save_my_changes
    and_I_return_to_flow_page 
end

def when_I_edit_the_page(title:)
  page.find('.govuk-link', text: title).click 
end

def and_I_want_to_set_content_visibility
  editor.show_if_link.click 
end

def then_I_should_see_the_conditional_content_menu_option
  expect(editor).to have_show_if_link
end

def and_I_want_to_set_content_visibility
  editor.show_if_link.click 
end

def and_I_want_to_edit_content_visibility_for(component)
  when_I_want_to_edit_content_component_properties(component)
  then_I_should_see_the_conditional_content_menu_option
  and_I_want_to_set_content_visibility
  then_I_should_see_the_conditional_content_modal
end

def then_I_should_see_the_conditional_content_modal
  expect(editor).to have_conditional_content_modal
end

def and_I_set_display_to_conditional
  editor.conditional_content_modal.display_conditional_radio.choose() 
end

def and_I_set_display_to_never
  editor.conditional_content_modal.display_never_radio.choose() 
end

def when_I_select_a_component(expression, label)
  expression.component_select.select(label)
  sleep(0.5)
end

def and_I_select_an_operator(expression, text)
  expression.operator_select.select(text)
end

def and_I_select_an_answer(expression, text)
  expression.answer_select.select(text)
end

def when_I_update_conditional_content
  editor.conditional_content_modal.update_button.click 
  sleep(0.5)
end

def then_when_I_preview_the_page(page_title:)
    preview_page = when_I_preview_the_page(page_title) 
    within_window( preview_page ) do
      yield if block_given?
    end
end

  
