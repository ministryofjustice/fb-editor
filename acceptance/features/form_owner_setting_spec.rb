# require_relative '../spec_helper'

# feature 'Form owner settings page' do
#   let(:editor) { EditorApp.new }
#   let(:service_name) { generate_service_name }
#   let(:new_form_owner) { 'fb-acceptance-tests@digital.justice.gov.uk' }

#   background do
#     editor.load
#     given_I_am_logged_in
#     given_I_have_a_service
#     and_I_go_to_update_the_form_owner_in_settings
#   end

#   scenario 'validates the form owner' do
#     given_I_update_the_form_owner('')
#     then_I_should_see_a_validation_message_for_missing_email
#   end

#   scenario 'validates the input is an email' do
#     given_I_update_the_form_owner('hi')
#     then_I_should_see_a_validation_message_for_invalid_email
#   end

#   scenario 'validates the user is present' do
#     given_I_update_the_form_owner('unknown@user')
#     then_I_should_see_a_validation_message_for_unknown_user
#   end

#    scenario 'updates the service owner in metadata and will be redirected to the forms list' do
#     given_I_update_the_form_owner(new_form_owner)
#     then_I_should_be_redirected_to_my_forms
#     then_I_should_see_the_modal_for_email_confirmation
#   end

#   def and_I_go_to_update_the_form_owner_in_settings
#     editor.load
#     editor.edit_service_link(service_name).click
#     editor.settings_link.click
#     editor.form_ownership_link.click
#   end

#   def given_I_update_the_form_owner(updated_form_owner)
#     form_owner_field.set(updated_form_owner)
#     editor.transfer_ownership_button.click
#   end

#   def then_I_should_be_redirected_to_my_forms
#     expect(editor).to have_content('Your forms')
#   end


#   def then_I_should_see_a_validation_message_for_missing_email
#     expect(editor).to have_content(I18n.t('activemodel.errors.models.transfer_ownership.blank'))
#   end

#   def then_I_should_see_a_validation_message_for_invalid_email
#     expect(editor).to have_content(I18n.t('activemodel.errors.models.transfer_ownership.invalid'))
#   end

#   def then_I_should_see_a_validation_message_for_unknown_user
#     expect(editor).to have_content(I18n.t('activemodel.errors.models.transfer_ownership.unknown_user'))
#   end


#   def then_I_should_see_the_modal_for_email_confirmation
#     expect(editor).to have_content(I18n.t('settings.transfer_ownership.confirmation_title'))
#     modal_understood_button
#   end

#   def form_owner_field
#     page.find(:css, 'input#form-owner-settings-form-owner-field')
#   end

#   def modal_understood_button
#     within('[data-component="OwnershipTransferDialog"]') do
#       all('button[type="submit"]').first
#     end
#   end
# end
