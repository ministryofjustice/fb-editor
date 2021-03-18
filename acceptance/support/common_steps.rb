module CommonSteps
  def given_I_am_logged_in
    editor.load
    editor.sign_in_button.click
    editor.sign_in_email_field.set('form-builder-developers@digital.justice.gov.uk')
    editor.sign_in_submit.click
  end

  def given_I_have_a_service(service = service_name)
    editor.load
    given_I_want_to_create_a_service
    given_I_add_a_service(service)
    when_I_create_the_service
  end
  alias when_I_try_to_create_a_service_with_the_same_name given_I_have_a_service

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

  def given_I_add_a_single_question_page_with_text
    given_I_want_to_add_a_single_question_page
    editor.add_single_question_text.click
  end

  def given_I_add_a_single_question_page_with_text_area
    given_I_want_to_add_a_single_question_page
    editor.add_single_question_text_area.click
  end

  def given_I_add_a_single_question_page_with_number
    given_I_want_to_add_a_single_question_page
    editor.add_single_question_number.click
  end

  def given_I_add_a_single_question_page_with_date
    given_I_want_to_add_a_single_question_page
    editor.add_single_question_date.click
  end

  def given_I_add_a_single_question_page_with_radio
    given_I_want_to_add_a_single_question_page
    editor.add_single_question_radio.click
  end

  def given_I_add_a_single_question_page_with_checkboxes
    given_I_want_to_add_a_single_question_page
    editor.add_single_question_checkboxes.click
  end

  def given_I_add_a_check_answers_page
    given_I_want_to_add_a_page
    editor.add_check_answers.click
  end

  def given_I_add_a_multiple_question_page
    given_I_want_to_add_a_page
    editor.add_multiple_question.click
  end

  def given_I_add_a_confirmation_page
    given_I_want_to_add_a_page
    editor.add_confirmation.click
  end

  def given_I_want_to_add_a_single_question_page
    given_I_want_to_add_a_page
    editor.add_single_question.hover
  end

  def given_I_want_to_add_a_page
    editor.add_page.click
  end

  def and_I_edit_the_service
    visit '/services'
    editor.edit_service_link(service_name).click
  end

  def and_I_return_to_flow_page
    editor.pages_link.click
  end

  def and_I_add_a_page_url
    editor.page_url_field.set(page_url)
  end

  def when_I_create_the_service
    editor.modal_create_service_button.click
  end

  def when_I_add_the_page
    editor.add_page_submit_button.last.click
  end
end
