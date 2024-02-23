require_relative '../spec_helper'

feature 'Edit multiple questions page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:url) { 'hakuna-matata' }
  let(:page_heading) { 'Hakuna Matata' }
  let(:text_component_question) do
    'C-3P0 is fluent in how many languages?'
  end
  let(:textarea_component_question) do
    'How Did Maz Kanata End Up With Luke`s Lightsaber?'
  end
  let(:email_component_question) do
    'What is your email address?'
  end
  let(:address_component_question) do
    'What is your postal address?'
  end

  let(:radio_component_question) do
    'How old is Yoda when he dies?'
  end
  let(:radio_component_options) { ['900 years old'] }
  let(:checkboxes_component_question) do
    'Tell us what are the star wars movies called'
  end
  let(:checkboxes_component_options) do
    ['Prequels']
  end
  let(:content_component) do
    'You underestimate the power of the Dark Side.'
  end
  let(:optional_content) do
    I18n.t('default_text.content')
  end

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(fixture: fixture)
  end

  context 'editing multiple questions page' do
    let(:fixture) { 'multiple_questions_page_fixture' }
    let(:move_page_question_titles) {
      [
        text_component_question,
        textarea_component_question,
        email_component_question,
        'editable_content'
      ]
    }
    let(:move_page_question_titles_reordered) {
      [
        textarea_component_question,
        text_component_question,
        'editable_content',
        email_component_question
      ]
    }

    scenario 'adding and updating components' do
      and_I_edit_the_page(url: page_heading)
      then_the_save_button_should_be_disabled
      expect(editor).to have_components_container
      and_I_add_the_component(I18n.t('components.list.text'))
      and_I_add_the_component(I18n.t('components.list.textarea'))
      and_I_add_the_component(I18n.t('components.list.email'))
      and_I_add_the_component(I18n.t('components.list.radios'))
      and_I_add_the_component(I18n.t('components.list.checkboxes'))
      and_I_add_the_component(I18n.t('components.list.address'))
      expect(editor.components_container).to have_components(count: 6)
      then_the_save_button_should_be_disabled
      and_I_update_the_components
      then_I_should_be_warned_when_leaving_page
      when_I_save_my_changes
      and_I_return_to_flow_page
      preview_form = and_I_preview_the_form
      then_I_can_answer_the_questions_in_the_page(preview_form)
    end

    scenario 'deleting a text component' do
      and_I_edit_the_page(url: page_heading)
      and_I_add_the_component(I18n.t('components.list.text'))
      and_I_add_the_component(I18n.t('components.list.textarea'))
      and_I_change_the_text_component(text_component_question)
      then_I_should_be_warned_when_leaving_page
      when_I_save_my_changes
      when_I_want_to_select_component_properties('h2', text_component_question)
      and_I_want_to_delete_a_component(text_component_question)
      when_I_save_my_changes
      and_the_component_is_deleted(text_component_question, remaining: 1)
    end

    scenario 'deleting an email component' do
      and_I_edit_the_page(url: page_heading)
      and_I_add_the_component(I18n.t('components.list.text'))
      and_I_add_the_component(I18n.t('components.list.textarea'))
      and_I_add_the_component(I18n.t('components.list.email'))
      and_I_change_the_email_component(email_component_question)
      then_I_should_be_warned_when_leaving_page
      when_I_save_my_changes
      when_I_want_to_select_component_properties('h2', email_component_question)
      and_I_want_to_delete_a_component(email_component_question)
      when_I_save_my_changes
      and_the_component_is_deleted(email_component_question, remaining: 2)
    end

    scenario 'moving_components' do 
      and_I_edit_the_page(url: page_heading)

      and_I_add_the_component(I18n.t('components.list.text'))
      and_I_add_the_component(I18n.t('components.list.textarea'))
      and_I_add_the_component(I18n.t('components.list.email'))
      and_I_add_a_content_component(content: 'This is my content')

      and_I_change_the_text_component(text_component_question)
      and_I_change_the_email_component(email_component_question)
      and_I_change_the_textarea_component(textarea_component_question)

      when_I_save_my_changes

      then_the_components_should_be_in_order(move_page_question_titles)
      then_the_first_component_should_not_have_an_up_button
      then_the_middle_components_should_have_up_and_down_buttons 
      then_the_last_component_should_not_have_a_down_button

      editor.components_container.within do |container|
        when_I_move_a_component_down(container.first_component) 
        when_I_move_a_component_up(container.last_component)
      end

      then_the_save_button_should_be_enabled
      then_the_components_should_be_in_order(move_page_question_titles_reordered)

      when_I_save_my_changes
      then_the_components_should_be_in_order(move_page_question_titles_reordered)

      and_I_return_to_flow_page
      preview_page = when_I_preview_the_page(page_heading)

      within_window(preview_page) do
        then_the_components_should_be_in_order(move_page_question_titles_reordered)
      end
    end

    scenario 'deleting content components' do
      and_I_edit_the_page(url: page_heading)
      then_I_add_a_content_component(
        content: content_component
      )
      when_I_save_my_changes
      then_I_should_see_my_content(content_component)

      when_I_want_to_select_component_properties('[data-element="editable-content-output"]', content_component)
      and_I_want_to_delete_a_content_component
      when_I_save_my_changes
      then_I_should_not_see_my_content(content_component)
    end
  end

  context 'a form with branches' do
    let(:fixture) { 'two_branching_points_fixture' }

    scenario 'deleting a component not used for branching' do
      and_I_edit_the_page(url: 'Page g')
      when_I_want_to_select_component_properties('h2', 'Question 1')
      and_I_want_to_delete_a_component('Question 1')
      and_the_component_is_deleted('Question 1', remaining: 1)
    end

    scenario 'deleting a component used for branching' do
      and_I_edit_the_page(url: 'Page g')
      when_I_want_to_select_component_properties('h2', 'Question 2')
      and_I_want_to_delete_a_branching_component('Question 2')
      and_the_component_is_not_deleted('Question 2', remaining: 2)
    end
  end

  def when_I_save_my_changes
    # click outside of fields that will make save button re-enable
    editor.service_name.click
    then_the_save_button_should_be_enabled
    editor.save_page_button.click
    then_the_save_button_should_be_disabled
  end


  def then_I_add_a_content_component(content:)
    and_I_add_a_component
    and_I_add_a_content_area
    expect(editor.first_component.find('[data-element="editable-content-output"]', visible: :all).text).to eq(optional_content)
    when_I_change_editable_content(editor.first_component, content: content)
  end

  def then_I_can_answer_the_questions_in_the_page(preview_form)
    within_window(preview_form) do
      expect(page).to have_content('Service name goes here')
      page.click_button 'Start now'
      page.fill_in 'C-3P0 is fluent in how many languages?',
        with: 'Fluent in over six million forms of communication.'
      page.fill_in 'How Did Maz Kanata End Up With Luke`s Lightsaber?',
        with: 'Who knows?'
      page.fill_in 'What is your email address?',
        with: 'healthy.harold@justice.gov.uk'
      page.choose '900 years old', visible: false
      page.check 'Prequels', visible: false
      page.fill_in 'Address line 1', with: '999'
      page.fill_in 'Town or city', with: 'Bat city'
      page.fill_in 'Postcode', with: 'SW1H 9AJ'
      page.click_button 'Continue'
      expect(page).to have_content("Check your answers")
    end
  end

  def and_the_component_is_deleted(question, remaining:)
    expect(page).to_not have_selector('h2', text: question)
    expect(page).to have_selector('.Question', count: remaining)
  end

  def and_the_component_is_not_deleted(question, remaining: )
    expect(page).to have_selector('h2', text: question)
    expect(page).to have_selector('.Question', count: remaining)
  end

  def then_the_components_should_be_in_order(titles)
    expect(editor.components_container.component_titles).to eq titles
  end
  

  def then_the_first_component_should_not_have_an_up_button
    editor.components_container.within do |container|
      container.first_component.activate
      expect(container.first_component).to have_down_button
      expect(container.first_component).to_not have_up_button
    end
  end

  def then_the_middle_components_should_have_up_and_down_buttons
    editor.components_container.within do |container|
      container.components.each_with_index do |component, index|
        next if index == 0
        next if index == container.components.length - 1

        component.activate
        expect(component).to have_down_button
        expect(component).to have_up_button
      end
    end
  end

  def then_the_last_component_should_not_have_a_down_button
    editor.components_container.within do |container|
      container.last_component.activate
      expect(container.last_component).to_not have_down_button
      expect(container.last_component).to have_up_button
    end
  end

  def when_I_move_a_component_up(component)
    component.activate
    component.up_button.click
  end

  def when_I_move_a_component_down(component)
    component.activate
    component.down_button.click
  end


end
