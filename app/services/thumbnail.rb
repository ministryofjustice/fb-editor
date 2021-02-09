class Thumbnail
  attr_reader :page, :service

  def initialize(page:, service:)
    @page = page
    @service = service
  end

  def create
    html = MetadataPresenter::PagesController.render(
      page.template,
      assigns: { page: page, service: service, user_data: {} }
    )

    absolute_html = Grover::HTMLPreprocessor.process html,
      'http://localhost:3001/', 'http'

    image_path = Rails.root.join(
      'public', 'thumbnails', "#{page.uuid}.png"
    ).to_s

    Grover.new(absolute_html).to_png(image_path)
  end
end
