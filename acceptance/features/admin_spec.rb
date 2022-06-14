require_relative '../spec_helper'

feature 'Visiting admin pages' do
  let(:editor) { EditorApp.new }
  let(:admin_pages) do
    %w(
      admin
      admin/overviews
      admin/services
      admin/users
      admin/publish_services
    )
  end

  scenario 'when not logged in' do
    admin_pages.each do |path|
      given_I_visit_an_admin_page(path)
      then_I_should_be_redirected_to_login
    end
  end

  # acceptance test user does not have permission to visit admin dashboards
  scenario 'when logged in' do
    given_I_am_logged_in
    then_I_should_not_see_the_admin_link
    admin_pages.each do |path|
      given_I_visit_an_admin_page(path)
      then_I_should_be_redirected_to_the_unauthorised_page
    end
  end

  def given_I_visit_an_admin_page(path)
    visit(File.join(ENV['ACCEPTANCE_TESTS_EDITOR_APP'], path))
  end

  def then_I_should_be_redirected_to_login
    expect(page.current_path).to eq('/')
    expect(page.title).to eq(I18n.t('home.show.title'))
    expect(page).to have_content(I18n.t('home.show.sign_in'))
  end

  def then_I_should_be_redirected_to_the_unauthorised_page
    expect(page.current_path).to eq('/unauthorised')
    expect(page).to have_content(I18n.t('auth.unauthorised.heading'))
    expect(page).to have_content(I18n.t('auth.unauthorised.body'))
  end

  def then_I_should_not_see_the_admin_link
    expect(page).not_to have_content(I18n.t('partials.header.admin'))
  end

  def then_I_should_be_redirected_to_the_services_page
    expect(page.current_path).to eq('/services')
    expect(editor.question_heading.first.text).to eq(I18n.t('services.heading'))
  end
end
