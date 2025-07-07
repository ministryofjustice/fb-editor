# require_relative '../spec_helper'

# feature 'Deleting page' do
#   let(:editor) { EditorApp.new }
#   let(:service_name) { generate_service_name }

#   background do
#     given_I_am_logged_in
#     given_I_have_a_service_fixture(fixture: 'two_branching_points_fixture')
#   end

#   scenario 'change destination to another page' do
#     given_I_want_to_change_destination_of_a_page('Page b')
#     when_I_change_destination_to_page('Page j')
#     then_I_should_not_see_unconnected_pages
#     then_page_j_should_be_after_page_b
#     then_some_pages_should_be_unconnected
#     given_I_want_to_change_destination_of_a_page('Page b')
#     then_I_should_see_unconnected_pages
#   end

#   scenario 'change destination in the middle of a branch' do
#     given_I_want_to_change_destination_of_a_page('Page b')
#     when_I_change_destination_to_page('Page d')
#     then_I_should_not_see_unconnected_pages
#     then_page_d_should_be_after_page_b
#     and_the_branching_should_be_unconnected
#     given_I_want_to_change_destination_of_a_page('Page b')
#     then_I_should_see_unconnected_pages
#   end

#   def then_I_should_not_see_unconnected_pages
#     expect(editor).not_to have_selector('.destination-optgroup')
#   end

#   def then_I_should_see_unconnected_pages
#     expect(editor).to have_selector('.destination-optgroup')
#   end

#   def then_page_j_should_be_after_page_b
#     expect(editor.page_flow_items).to eq(
#       [
#         'Service name goes here',
#         'Page b',
#         'Page j',
#         'Check your answers',
#         'Application complete'
#       ]
#     )
#   end

#   def then_some_pages_should_be_unconnected
#     page.driver.browser.manage.window.resize_to(30000, 1080)
#     expect(editor.unconnected_flow).to eq(
#       [
#         'Branching point 1',
#         'Page c',
#         'Page d',
#         'Page e',
#         'Page f',
#         'Page g',
#         'Branching point 2',
#         'Page h',
#         'Page i',
#         'Page j'
#       ]
#     )
#   end

#   def then_page_d_should_be_after_page_b
#     expect(editor.page_flow_items).to eq([
#       'Service name goes here',
#       'Page b',
#       'Page d',
#       'Page e',
#       'Page f',
#       'Page g',
#       'Page h',
#       'Page i',
#       'Page j',
#       'Check your answers',
#       'Application complete'
#     ])
#   end

#   def and_the_branching_should_be_unconnected
#     page.driver.browser.manage.window.resize_to(30000, 1080)
#     expect(editor.unconnected_flow).to eq([
#       'Branching point 1',
#       'Page c',
#       'Page e',
#       'Page g',
#       'Page d'
#     ])
#   end
# end
