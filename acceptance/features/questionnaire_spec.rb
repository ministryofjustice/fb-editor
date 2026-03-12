require_relative '../spec_helper'

feature 'Questionnaire' do
  let(:editor) { EditorApp.new }

  scenario 'Building a form and ruling out GOV.UK Forms' do
    given_I_am_logged_in(admin: false)
    click_link I18n.t('services.create')

    # get_started
    expect(page).to have_content(I18n.t('questionnaire.get_started_form.heading'))
    choose I18n.t('activemodel.attributes.questionnaire/get_started_form/new_form_reason.building'), allow_label_click: true
    click_button I18n.t('dialogs.button_continue')

    # gov_forms
    expect(page).to have_content(I18n.t('questionnaire.gov_forms_form.heading'))
    choose I18n.t('activemodel.attributes.questionnaire/gov_forms/govuk_forms_ruled_out.true'), allow_label_click: true
    click_button I18n.t('dialogs.button_continue')

    # form_features
    expect(page).to have_content(I18n.t('questionnaire.form_features_form.heading'))
    check I18n.t('activemodel.attributes.questionnaire/form_features_form/required_moj_forms_features.multiple_questions'), allow_label_click: true
    fill_in I18n.t('questionnaire.form_features_form.label.text'), with: 'Because I want to use MoJ Forms'
    click_button I18n.t('dialogs.button_continue')

    # new_form
    expect(page).to have_content(I18n.t('questionnaire.new_form_form.heading'))
    choose I18n.t('activemodel.attributes.questionnaire/new_form_form/estimated_page_count.under_20'), allow_label_click: true
    choose I18n.t('activemodel.attributes.questionnaire/new_form_form/estimated_first_year_submissions_count.under_10000'), allow_label_click: true
    choose I18n.t('activemodel.attributes.questionnaire/new_form_form/submission_delivery_method.email'), allow_label_click: true
    click_button I18n.t('dialogs.button_continue')

    # requirements
    expect(page).to have_content(I18n.t('questionnaire.requirements.heading'))
    click_link I18n.t('dialogs.button_continue')

    # services/new
    expect(page).to have_content(I18n.t('activemodel.attributes.service_creation.service_name'))
  end

  scenario 'Building a form and NOT ruling out GOV.UK Forms but continuing anyway' do
    given_I_am_logged_in(admin: false)
    click_link I18n.t('services.create')

    # get_started
    choose I18n.t('activemodel.attributes.questionnaire/get_started_form/new_form_reason.building'), allow_label_click: true
    click_button I18n.t('dialogs.button_continue')

    # gov_forms
    choose I18n.t('activemodel.attributes.questionnaire/gov_forms/govuk_forms_ruled_out.false'), allow_label_click: true
    click_button I18n.t('dialogs.button_continue')

    # continue
    expect(page).to have_content(I18n.t('questionnaire.continue_form.heading'))
    choose I18n.t('activemodel.attributes.questionnaire/continue_form/continue_with_moj_forms.true'), allow_label_click: true
    click_button I18n.t('dialogs.button_continue')

    # new_form
    expect(page).to have_content(I18n.t('questionnaire.new_form_form.heading'))
    choose I18n.t('activemodel.attributes.questionnaire/new_form_form/estimated_page_count.under_20'), allow_label_click: true
    choose I18n.t('activemodel.attributes.questionnaire/new_form_form/estimated_first_year_submissions_count.under_10000'), allow_label_click: true
    choose I18n.t('activemodel.attributes.questionnaire/new_form_form/submission_delivery_method.email'), allow_label_click: true
    click_button I18n.t('dialogs.button_continue')

    # requirements
    expect(page).to have_content(I18n.t('questionnaire.requirements.heading'))
    click_link I18n.t('dialogs.button_continue')

    # services/new
    expect(page).to have_content(I18n.t('activemodel.attributes.service_creation.service_name'))
  end

  scenario 'Just experimenting' do
    given_I_am_logged_in(admin: false)
    click_link I18n.t('services.create')

    # get_started
    choose I18n.t('activemodel.attributes.questionnaire/get_started_form/new_form_reason.experiment'), allow_label_click: true
    click_button I18n.t('dialogs.button_continue')

    # great_choice
    expect(page).to have_content(I18n.t('questionnaire.great_choice.heading'))
    click_link I18n.t('dialogs.button_continue')

    # services/new
    expect(page).to have_content(I18n.t('activemodel.attributes.service_creation.service_name'))
  end

  scenario 'Building a form and NOT ruling out GOV.UK Forms and NOT continuing' do
    given_I_am_logged_in(admin: false)
    click_link I18n.t('services.create')

    # get_started
    choose I18n.t('activemodel.attributes.questionnaire/get_started_form/new_form_reason.building'), allow_label_click: true
    click_button I18n.t('dialogs.button_continue')

    # gov_forms
    choose I18n.t('activemodel.attributes.questionnaire/gov_forms/govuk_forms_ruled_out.false'), allow_label_click: true
    click_button I18n.t('dialogs.button_continue')

    # continue
    choose I18n.t('activemodel.attributes.questionnaire/continue_form/continue_with_moj_forms.false'), allow_label_click: true
    click_button I18n.t('dialogs.button_continue')

    # exit
    expect(page).to have_content(I18n.t('questionnaire.exit.heading'))
    click_link I18n.t('dialogs.link_back_to_your_forms')

    # services index
    expect(page).to have_content(I18n.t('services.heading'))
  end
end
