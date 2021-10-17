require_relative '../support/data_content_id'

class EditorApp < SitePrism::Page
  extend DataContentId

  if ENV['ACCEPTANCE_TESTS_USER'] && ENV['ACCEPTANCE_TESTS_PASSWORD']
    set_url sprintf(ENV['ACCEPTANCE_TESTS_EDITOR_APP'], user: ENV['ACCEPTANCE_TESTS_USER'], password: ENV['ACCEPTANCE_TESTS_PASSWORD'])
  else
    set_url ENV['ACCEPTANCE_TESTS_EDITOR_APP']
  end

  # landing page
  element :sign_in_button, :button, 'Sign in'

  # localhost
  element :sign_in_email_field, :field, 'Email:'
  element :sign_in_submit, :button, 'Sign In'

  # Auth0
  # currently not used as we are interacting with the fields using JS
  # these will be used again in the future
  element :email_address_field, :field, 'Email'
  element :password_field, :field, 'Password'
  element :login_continue_button, :button, 'Log In'

  element :service_name, '#form-navigation-heading'
  element :name_field, :field, 'Give your form a name'
  element :create_service_button, :button, 'Create a new form'

  element :footer_pages_links, 'summary'
  element :cookies_link, :link, 'cookies'

  element :pages_link, :link, 'Pages'
  element :settings_link, :link, 'Settings'
  element :form_details_link, :link, 'Form details'
  element :form_name_field, :field, 'Form name'
  element :save_button, :button, 'Save'
  element :preview_form_button, :link, 'Preview form'

  element :submission_settings_link, :link, 'Submission settings'
  element :send_by_email_link, :link, 'Send by email'

  element :page_url_field, :field, 'Give your page a short name'
  element :new_page_form, '#new_page', visible: false

  element :add_page, :button, 'Add page'
  element :add_single_question,
          :xpath,
          "//span[@class='ui-menu-item-wrapper' and contains(.,'Single question page')]"
  element :add_multiple_question,
          :xpath,
          "//a[@class='ui-menu-item-wrapper' and contains(.,'Multiple question page')]"
  element :add_check_answers,
          :xpath,
          "//a[@class='ui-menu-item-wrapper' and contains(.,'Check answers page')]"
  element :add_confirmation,
          :xpath,
          "//a[@class='ui-menu-item-wrapper' and contains(.,'Confirmation page')]"
  element :add_content_page,
          :xpath,
          "//a[@class='ui-menu-item-wrapper' and contains(.,'Content page')]"
  element :add_exit,
          :xpath,
          "//a[@class='ui-menu-item-wrapper' and contains(.,'Exit page')]"

  element :add_a_component_button, :link, I18n.t('components.actions.add_component')
  element :question_component,
          :xpath,
          "//*[@role='menuitem' and contains(.,'Question')]"
  element :content_component,
          :xpath,
          "//a[@class='ui-menu-item-wrapper' and contains(.,'Content area')]"

  element :question_three_dots_button, '.ActivatedMenu_Activator'
  element :required_question,
          :xpath,
          "//span[@class='ui-menu-item-wrapper' and contains(.,'Required...')]"

  element :add_text, :link, I18n.t('components.list.text'), visible: false
  element :add_text_area, :link, I18n.t('components.list.textarea'), visible: false
  element :add_number, :link, I18n.t('components.list.number'), visible: false
  element :add_file_upload, :link, I18n.t('components.list.upload'), visible: false
  element :add_date, :link, I18n.t('components.list.date'), visible: false
  element :add_radio, :link, I18n.t('components.list.radios'), visible: false
  element :add_checkboxes, :link, I18n.t('components.list.checkboxes'), visible: false
  element :add_content, :link, I18n.t('components.menu.content_area'), visible: false

  elements :add_page_submit_button, :button, I18n.t('pages.create')
  element :save_page_button, :xpath, '//input[@value="Save"]'

  elements :radio_options, :xpath, '//input[@type="radio"]', visible: false
  elements :checkboxes_options, :xpath, '//input[@type="checkbox"]', visible: false

  elements :question_heading, 'h1'
  elements :component_heading, 'h2'
  elements :all_hints, '.govuk-hint'
  elements :editable_options, '.EditableComponentCollectionItem label'
  element :question_hint, '.govuk-hint'
  data_content_id :section_heading, 'page[section_heading]'
  data_content_id :page_heading, 'page[heading]'
  data_content_id :page_lede, 'page[lede]'
  data_content_id :page_body, 'page[body]'
  data_content_id :page_send_heading, 'page[send_heading]'
  data_content_id :page_send_body, 'page[send_body]'

  elements :add_content_area_buttons, :link, 'Add content area'
  data_content_id :first_component, 'page[components[0]]'
  data_content_id :second_component, 'page[components[1]]'
  data_content_id :first_extra_component, 'page[extra_components[0]]'

  elements :form_pages, '.form-step'
  elements :form_urls, '.form-step a.govuk-link'
  elements :preview_page_images, '.form-step img.body'
  element :three_dots_button, '.flow-menu-activator'
  element :preview_page_link, :link, I18n.t('actions.preview_page')
  element :add_page_here_link, :link, I18n.t('actions.add_page')
  element :delete_page_link, :link, I18n.t('actions.delete_page')
  element :delete_page_modal_button, :button, I18n.t('dialogs.button_delete_page')
  element :branching_link, :link, I18n.t('services.branch')

  element :add_condition, :button, I18n.t('branches.condition_add')
  element :remove_condition, :button, I18n.t('branches.condition_remove') # bin icon
  element :remove_condition_button, :button, I18n.t('dialogs.button_delete_condition') # dialog confirmation
  element :add_another_branch, :link, I18n.t('branches.branch_add')
  element :conditional_three_dot, :button, '.ActivatedMenu_Activator'
  element :remove_branch_button, :button, I18n.t('dialogs.button_delete_branch')

  element :destination_options, '#branch_conditionals_attributes_0_next'
  element :conditional_options, '#branch_conditionals_attributes_0_expressions_attributes_0_component'
  element :operator_options, '#branch_conditionals_attributes_0_expressions_attributes_0_operator'
  element :field_options, '#branch_conditionals_attributes_0_expressions_attributes_0_field'
  element :otherwise_options, '#branch_default_next'

  def edit_service_link(service_name)
    find("#service-#{service_name.parameterize} .edit")
  end

  def modal_create_service_button
    all('.ui-dialog-buttonpane button').first
  end

  def branch_title(index)
    find("div[data-conditional-index='#{index}'] p")
  end
end
