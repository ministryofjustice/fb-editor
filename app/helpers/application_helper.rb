module ApplicationHelper
  include MetadataPresenter::ApplicationHelper

  def display_thumbnail(page:, service:)
    html = MetadataPresenter::PagesController.render(
      page.template,
      assigns: { page: page, service: service, user_data: {} })

    absolute_html = Grover::HTMLPreprocessor.process html,
      'http://localhost:3001/', 'http'

    image_path = Rails.root.join('public', "#{page.uuid}.png").to_s

    if File.exist?(image_path)
      %{<img src='/#{page.uuid}.png' alt='thumbnail' />}.html_safe
    else
      Grover.new(absolute_html).to_png(image_path)
    end
  end
end
