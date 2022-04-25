require_relative '../spec_helper'

feature 'Page menu items' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }
  let(:two_menu_items) do
    [
      I18n.t('actions.edit_page'),
      I18n.t('actions.preview_page')
    ]
  end
  let(:three_menu_items) do
    [
      I18n.t('actions.edit_page'),
      I18n.t('actions.preview_page'),
      I18n.t('actions.delete_page')
    ]
  end
  let(:four_menu_items) do
    [
      I18n.t('actions.edit_page'),
      I18n.t('actions.preview_page'),
      I18n.t('actions.move_page'),
      I18n.t('actions.delete_page')
    ]
  end
  let(:branching_menu_items) do
    [
      I18n.t('actions.edit_branch'),
      I18n.t('actions.delete_branch')
    ]
  end
  let(:start_page) { 'Service name goes here' }
  let(:page_d) { 'Page d' }
  let(:exit_page) { 'Exit page' }
  let(:branching_point) { 'Branching point 1' }
  let(:check_answers) { 'Check your answers' }
  let(:confirmation) { 'Application complete' }

  background do
    given_I_am_logged_in
    given_I_have_a_service_fixture(name: service_name)
  end

  scenario 'start page' do
    and_I_click_on_the_page_menu(start_page)
    then_I_should_see_the_expected_menu_items(start_page, two_menu_items)
  end

  scenario 'standard flow page' do
    and_I_click_on_the_page_menu(page_d)
    then_I_should_see_the_expected_menu_items(page_d, four_menu_items)
  end

  scenario 'exit page' do
    and_I_click_on_the_page_menu(exit_page)
    then_I_should_see_the_expected_menu_items(exit_page, four_menu_items)
  end

  scenario 'branching point' do
    and_I_click_on_the_branching_point_menu(branching_point)
    then_I_should_see_the_expected_menu_items(branching_point, branching_menu_items)
  end

  scenario 'check answers page' do
    and_I_click_on_the_page_menu(check_answers)
    then_I_should_see_the_expected_menu_items(check_answers, three_menu_items)
  end

  scenario('confirimation page') do
    and_I_click_on_the_page_menu(confirmation)
    then_I_should_see_the_expected_menu_items(confirmation, three_menu_items)
  end

  def then_I_should_see_the_expected_menu_items(flow_title, expected_menu_items)
    items = find("ul[data-title='#{flow_title}']").all('[role="menuitem"]').map(&:text)
    expect(items).to eq(expected_menu_items)
  end
end
