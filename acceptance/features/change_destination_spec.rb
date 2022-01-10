require_relative '../spec_helper'

feature 'Deleting page' do
  let(:editor) { EditorApp.new }
  let(:service_name) { generate_service_name }

  background do
    given_I_am_logged_in
    given_I_have_a_service
    given_I_have_a_form_with_pages
  end

  scenario 'change destination to another page' do
    given_I_want_to_change_destination_of_a_page('Page b')
    when_I_change_destination_to_page('Page j')
    then_page_j_should_be_after_page_b
    then_some_pages_should_be_unconnected
  end

  scenario 'change destination in the middle of a branch' do
    given_I_want_to_change_destination_of_a_page('Page b')
    when_I_change_destination_to_page('Page d')
    then_page_d_should_be_after_page_b
    and_the_branching_should_be_unconnected
  end

  def given_I_want_to_change_destination_of_a_page(page)
    editor.hover_preview(page)
    editor.three_dots_button.click
    editor.change_destination_link.click
  end

  def when_I_change_destination_to_page(page)
    select page
    editor.change_next_page_button.click
  end

  def then_cya_and_confirmation_pages_should_be_unconnected
    editor.unconnected_expand_link.click
    expect(editor.unconnected_flow).to eq(
      [
        'Check your answers',
        'Application complete'
      ]
    )
  end

  def then_page_j_should_be_after_page_b
    expect(editor.page_flow_items).to eq(
      [
        'Service name goes here',
        'Page b',
        'Page j',
        'Check your answers',
        'Application complete'
      ]
    )
  end

  def then_some_pages_should_be_unconnected
    editor.unconnected_expand_link.click
    expect(editor.unconnected_flow).to eq(
      [
        'Branching point 1',
        'Page b is Thor',
        'Page b is Hulk',
        'Otherwise',
        'Page c',
        'Page d',
        'Page e',
        'Page f',
        'Page g',
        'Branching point 2',
        'Page g is Thor',
        'Page h',
        'Page i',
        'Page j'
      ]
    )
  end

  def then_page_d_should_be_after_page_b
    expect(editor.page_flow_items).to eq([
      'Service name goes here',
      'Page b',
      'Page d',
      'Page e',
      'Page f',
      'Page g',
      'Page h',
      'Page i',
      'Page j',
      'Check your answers',
      'Application complete'
    ])
  end

  def and_the_branching_should_be_unconnected
    editor.unconnected_expand_link.click
    expect(editor.unconnected_flow).to eq([
      'Branching point 1',
      'Page b is Thor',
      'Page b is Hulk',
      'Otherwise',
      'Page c',
      'Page d'
    ])
  end
end
