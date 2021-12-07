require_relative '../spec_helper'

feature 'Branching errors' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:page_url) { 'palpatine' }
  let(:exit_url) { 'exit' }
  let(:warning_both) { I18n.t('publish.warning.both_pages') }
  let(:warning_cya) { I18n.t('publish.warning.cya') }
  let(:warning_confirmation) { I18n.t('publish.warning.confirmation') }

  background do
    given_I_am_logged_in
    given_I_have_a_service
  end

  scenario 'when visiting the publishing page with submitting pages present' do
    given_I_have_a_single_question_page_with_upload
    and_I_return_to_flow_page
    when_I_visit_the_publishing_page
    then_I_should_be_on_the_publishing_page
    then_I_should_not_see_warning_both_text
    then_I_should_not_see_warning_cya_text
    then_I_should_not_see_warning_confirmation_text
  end

  scenario 'when visiting the publishing page without submitting pages present' do
    given_I_have_a_single_question_page_with_upload
    and_I_return_to_flow_page
    given_I_have_an_exit_page
    when_I_visit_the_publishing_page
    then_I_should_be_on_the_publishing_page
    then_I_should_see_warning_both_text
    then_I_should_not_see_warning_cya_text
    then_I_should_not_see_warning_confirmation_text
  end

  scenario 'when visiting the publishing page without cya page present' do
    given_I_have_a_single_question_page_with_upload
    and_I_return_to_flow_page
    # this will fail when we implement delete warning
    and_I_delete_cya_page
    when_I_visit_the_publishing_page
    then_I_should_be_on_the_publishing_page
    then_I_should_not_see_warning_both_text
    then_I_should_not_see_warning_confirmation_text
    then_I_should_see_warning_cya_text
  end

  scenario 'when visiting the publishing page without confirmation page present' do
    given_I_have_a_single_question_page_with_upload
    and_I_return_to_flow_page
    # this will fail when we implement disconnected pages warning
    and_I_add_an_exit_page_after_cya_page
    when_I_visit_the_publishing_page
    then_I_should_be_on_the_publishing_page
    then_I_should_not_see_warning_both_text
    then_I_should_not_see_warning_cya_text
    then_I_should_see_warning_confirmation_text
  end

  def when_I_visit_the_publishing_page
    editor.publishing_link.click
  end

  def then_I_should_be_on_the_publishing_page
    expect(editor.question_heading.first.text).to eq(I18n.t('publish.heading'))
    buttons_text = page.all(:css, 'input.fb-govuk-button', visible: false).map(&:value)
    expect(buttons_text).to include(I18n.t('publish.test.button'))
    expect(buttons_text).to include(I18n.t('publish.live.button'))
  end

  def and_I_delete_cya_page
    sleep 0.5 # Arbitrary delay, possibly required due to focus issues
    editor.preview_page_images.last.hover
    editor.three_dots_button.click
    editor.delete_page_link.click
    sleep 0.5 # Arbitrary delay, possibly required due to focus issues
    editor.delete_page_modal_button.click
  end

  def and_I_add_an_exit_page_after_cya_page
    editor.preview_page_images.last.hover
    editor.three_dots_button.click
    editor.add_page_here_link.click
    editor.add_exit.click
    and_I_add_a_page_url(exit_url)
    when_I_add_the_page
  end

  def given_I_have_an_exit_page
    given_I_add_an_exit_page
    and_I_add_a_page_url(exit_url)
    when_I_add_the_page
  end

  def then_I_should_not_see_warning_both_text
    expect(editor.text).to_not include(warning_both)
  end

  def then_I_should_not_see_warning_cya_text
    expect(editor.text).to_not include(warning_cya)
  end

  def then_I_should_not_see_warning_confirmation_text
    expect(editor.text).to_not include(warning_confirmation)
  end

  def then_I_should_see_warning_both_text
    expect(editor.text).to include(warning_both)
  end

  def then_I_should_see_warning_cya_text
    expect(editor.text).to include(warning_cya)
  end

  def then_I_should_see_warning_confirmation_text
    expect(editor.text).to include(warning_confirmation)
  end
end
