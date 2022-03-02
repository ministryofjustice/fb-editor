module CommonSteps
  OPTIONAL_TEXT = [
    I18n.t('default_text.section_heading'),
    I18n.t('default_text.lede'),
    I18n.t('default_text.content'),
    I18n.t('default_text.option_hint')
  ].freeze
  ERROR_MESSAGE = 'There is a problem'.freeze
  DELETE_WARNING = [
    I18n.t('pages.flow.delete_warning_cya_page'),
    I18n.t('pages.flow.delete_warning_confirmation_page'),
    I18n.t('pages.flow.delete_warning_both_pages')
  ].freeze

  def given_I_am_logged_in
    editor.load
    editor.sign_in_button.click

    if ENV['CI_MODE'].present?
      sleep(3)
      expect(page).to have_content('Please select the log in option that matches your work email')

      # Executing javascript directly as the fields and button are hidden on the
      # login page for the moment
      editor.execute_script(
        "document.getElementById('email').value = '#{ENV['ACCEPTANCE_TESTS_USER']}'"
      )
      editor.execute_script(
        "document.getElementById('password').value = '#{ENV['ACCEPTANCE_TESTS_PASSWORD']}'"
      )
      editor.execute_script(
        "document.getElementById('btn-login').click()"
      )
    else
      editor.sign_in_email_field.set('form-builder-developers@digital.justice.gov.uk')
      editor.sign_in_submit.click
    end

    sleep(3)
    expect(page).to have_content(I18n.t('services.create'))
  end

  def given_I_have_a_service(service = service_name)
    editor.load
    given_I_want_to_create_a_service
    given_I_add_a_service(service)
    when_I_create_the_service
  end
  alias_method :when_I_try_to_create_a_service_with_the_same_name, :given_I_have_a_service

  def given_I_have_another_service
    given_I_have_a_service(another_service_name)
  end

  def given_I_add_a_service(service = service_name)
    editor.name_field.set(service)
  end

  def given_I_want_to_create_a_service
    editor.create_service_button.click
  end

  def given_I_have_a_single_question_page_with_text
    given_I_add_a_single_question_page_with_text
    and_I_add_a_page_url
    when_I_add_the_page
  end

  def given_I_have_a_single_question_page_with_upload
    given_I_add_a_single_question_page_with_upload
    and_I_add_a_page_url
    when_I_add_the_page
  end

  def given_I_add_a_single_question_page_with_text
    given_I_want_to_add_a_single_question_page
    editor.add_text.click
  end

  def given_I_add_a_single_question_page_with_text_area
    given_I_want_to_add_a_single_question_page
    editor.add_text_area.click
  end

  def given_I_add_a_single_question_page_with_number
    given_I_want_to_add_a_single_question_page
    editor.add_number.click
  end

  def given_I_add_a_single_question_page_with_upload
    given_I_want_to_add_a_single_question_page
    editor.add_file_upload.click
  end

  def given_I_add_a_single_question_page_with_date
    given_I_want_to_add_a_single_question_page
    editor.add_date.click
  end

  def given_I_add_a_single_question_page_with_radio
    given_I_want_to_add_a_single_question_page
    editor.add_radio.click
  end

  def given_I_add_a_single_question_page_with_checkboxes
    given_I_want_to_add_a_single_question_page
    editor.add_checkboxes.click
  end

  def given_I_add_a_single_question_page_with_email
    given_I_want_to_add_a_single_question_page
    editor.add_email.click
  end

  def given_I_add_a_check_answers_page
    editor.preview_page_images.first.hover
    editor.three_dots_button.click
    editor.add_page_here_link.click
    editor.add_check_answers.click
  end

  def given_I_edit_a_check_your_answers_page
    page.find('.govuk-link', text: 'Check your answers').click
  end

  def given_I_add_a_content_page
    given_I_want_to_add_a_page
    editor.add_content_page.click
  end

  def given_I_add_a_multiple_question_page
    given_I_want_to_add_a_page
    editor.add_multiple_question.click
  end

  def given_I_add_a_confirmation_page
    given_I_want_to_add_a_page
    editor.add_confirmation.click
  end

  def given_I_edit_a_confirmation_page
    page.find('.govuk-link', text: 'Application complete').click
  end

  def given_I_add_an_exit_page
    given_I_want_to_add_a_page
    editor.add_exit.click
    and_I_add_a_page_url(exit_url)
    when_I_add_the_page
  end

  def given_I_want_to_add_a_single_question_page
    given_I_want_to_add_a_page
    editor.add_exit.hover # This is to prevent menu overlay and hiding text
    editor.add_single_question.hover
  end

  def given_I_want_to_add_a_page
    and_I_click_on_the_three_dots
    editor.add_page_here_link.click
  end

  def and_I_edit_the_service
    visit '/services'
    editor.edit_service_link(service_name).click
  end

  def and_I_edit_the_page(url:)
    page.find('.govuk-link', text: url).click
  end

  def and_I_return_to_flow_page
    editor.pages_link.click
  end

  def and_I_change_the_page_heading(heading)
    editor.page_heading.set(heading)
  end

  def then_I_see_the_updated_page_heading(heading)
    expect(editor.page_heading.text).to eq(heading)
  end

  def and_I_change_the_page_section_heading(section_heading)
    editor.section_heading.set(section_heading)
  end

  def then_I_see_the_updated_page_section_heading(section_heading)
    editor.section_heading.set(section_heading)
  end

  def and_I_change_the_page_lede(lede)
    editor.page_lede.set(lede)
  end

  def then_I_see_the_updated_page_lede(lede)
    editor.page_lede.set(lede)
  end

  def when_I_create_the_service
    editor.modal_create_service_button.click
  end

  def when_I_add_the_page
    editor.add_page_submit_button.last.click
  end

  def when_I_preview_the_page
    editor.preview_page_images[-2].hover
    when_I_click_preview_page
  end

  def when_I_click_preview_page
    editor.three_dots_button.click

    window_opened_by do
      editor.preview_page_link.click
    end
  end

  def then_I_should_preview_the_page(preview_page)
    within_window(preview_page) do
      expect(page.find('[type="submit"]')).to_not be_disabled
      expect(page.text).to include('Question')
      then_I_should_not_see_optional_text
      yield if block_given?
    end
  end

  def when_I_save_my_changes
    # click outside of fields that will make save button re-enable
    editor.service_name.click
    expect(editor.save_page_button).to_not be_disabled
    editor.save_page_button.click
  end

  def when_I_want_to_select_question_properties
    editor.question_heading.first.click
    editor.question_three_dots_button.click
    expect(editor).not_to have_css('span', text: I18n.t('question.menu.remove'))
  end

  def and_I_want_to_set_a_question_optional
    editor.required_question.click
  end

  def and_I_update_the_question_to_be_optional
    editor.choose 'No', visible: false
    editor.click_button 'Update'
  end

  def given_I_have_a_single_question_page_with_radio
    given_I_add_a_single_question_page_with_radio
    and_I_add_a_page_url
    when_I_add_the_page
  end

  def and_I_preview_the_form
    window_opened_by do
      editor.preview_form_button.click
    end
  end

  def and_I_add_a_page_url(url = nil)
    path = if url.present?
      url
    else
      page_url # via let(:page_url) { }
    end

    editor.page_url_field.set(path)
  end

  def then_I_should_see_the_confirmation_heading(heading)
    expect(editor.page_heading.text).to eq(heading)
  end
  alias_method :then_I_should_see_the_page_heading, :then_I_should_see_the_confirmation_heading

  def given_I_have_a_check_your_answers_page
    given_I_add_a_check_answers_page
    and_I_add_a_page_url(url)
    when_I_add_the_page
  end
  alias_method :and_I_have_a_check_your_answers_page, :given_I_have_a_check_your_answers_page

  def when_I_preview_the_form
    and_I_return_to_flow_page
    and_I_preview_the_form
  end

  def when_I_change_editable_content(element, content:)
    # activate the input element for the content component by clicking on the
    # output element tag first
    element_output(element).click

    # the input element of the content component is what needs to be
    # interacted with in order to set a value
    element.find('.input', visible: false).set(content)

    # click outside to close the editable component
    editor.service_name.click
  end

  def element_output(element)
    # content component elements
    element.find('.output p', visible: false)
  rescue Capybara::ElementNotFound
    # body elements
    element.find('.output', visible: false)
  end

  def then_I_should_not_see_optional_text
    OPTIONAL_TEXT.each { |optional| expect(page.text).not_to include(optional) }
  end

  def then_I_should_see_an_error_message(*fields)
    expect(page.text).to include(ERROR_MESSAGE)
    if fields.empty?
      expect(page.text).to include('Enter an answer for')
    else
      fields.each { |field| expect(text).to include("Enter an answer for #{field}")}
    end
  end

  def then_I_should_see_my_content(*expected_text)
    expected_text.each { |text| expect(page.text).to include(text)}
  end

  def then_I_should_not_see_my_content(*expected_text)
    expected_text.each { |text| expect(page.text).to_not include(text)}
  end

  def when_I_want_to_select_component_properties(attribute, text)
    page.find(attribute, text: text).click
    page.first('.ActivatedMenu_Activator').click
  end

  def and_I_click_on_the_three_dots
    #sleep 1 # Arbitrary delay, possibly required due to focus issues
    # assuming the last two pages are checkanswers and confirmation, always pick
    # the page directly before the checkanswers page
    editor.wait_until_preview_page_images_visible
    editor.preview_page_images[-2].hover
    editor.three_dots_button.click
  end

  def then_I_should_only_see_three_options_on_page_menu
    options = all('.ui-menu-item').map(&:text)
    expect(options).to eq([
      I18n.t('actions.edit_page'),
      I18n.t('actions.preview_page'),
      I18n.t('actions.delete_page')
    ])
  end

  def then_I_should_not_be_able_to_add_page(page)
    editor.preview_page_images.first.hover
    editor.three_dots_button.click
    editor.add_page_here_link.click
    expect(editor.text).not_to include(page)
  end

  def then_I_should_be_able_to_add_page(page)
    editor.preview_page_images.first.hover
    editor.three_dots_button.click
    editor.add_page_here_link.click
    expect(editor.text).to include(page)
  end

  def then_I_should_see_default_service_pages
    expect(editor.form_urls.count).to eq(3)
  end

  def then_I_should_see_the_page_flow_in_order(order:)
    expect(editor.form_urls.map(&:text)).to eq(order)
  end

  def and_I_delete_cya_page
    sleep 1 # Arbitrary delay, possibly required due to focus issues
    editor.hover_preview('Check your answers')
    editor.three_dots_button.click
    editor.delete_page_link.click
    sleep 1 # Arbitrary delay, possibly required due to focus issues
    editor.delete_page_modal_button.click
  end

  def when_I_delete_confirmation_page
    sleep 1 # Arbitrary delay, possibly required due to focus issues
    editor.hover_preview('Application complete')
    editor.three_dots_button.click
    editor.delete_page_link.click
    sleep 1 # Arbitrary delay, possibly required due to focus issues
    editor.delete_page_modal_button.click
  end

  def then_I_should_not_see_delete_warnings
    expect(editor.text).not_to include(DELETE_WARNING[0])
    expect(editor.text).not_to include(DELETE_WARNING[1])
    expect(editor.text).not_to include(DELETE_WARNING[2])
  end

  def then_I_should_see_delete_warning_cya
    expect(editor.text).to include(DELETE_WARNING[0])
  end

  def then_I_should_see_delete_warning_confirmation
    expect(editor.text).to include(DELETE_WARNING[1])
  end

  def then_I_should_see_delete_warning_both
    expect(editor.text).to include(DELETE_WARNING[2])
  end
end
