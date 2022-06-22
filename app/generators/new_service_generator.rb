class NewServiceGenerator
  attr_reader :service_name, :current_user

  def initialize(service_name:, current_user:)
    @service_name = service_name
    @current_user = current_user
  end

  def to_metadata
    metadata = DefaultMetadata['service.base']

    metadata.tap do
      metadata['configuration']['service'] = DefaultMetadata['config.service']
      metadata['configuration']['meta'] = DefaultMetadata['config.meta']
      metadata['pages'].push(DefaultMetadata['page.start'])
      metadata['pages'][0]['_uuid'] = SecureRandom.uuid
      metadata['service_name'] = service_name
      metadata['created_by'] = current_user.id
    end

    metadata['flow'] = start_page_flow_object(metadata)
    metadata = add_cya_and_confirmation(metadata)
    metadata['standalone_pages'] = footer_pages
    metadata
  end

  private

  def start_page_flow_object(metadata)
    NewFlowPageGenerator.new(
      page_uuid: metadata['pages'][0]['_uuid'],
      latest_metadata: metadata
    ).to_metadata
  end

  def footer_pages
    I18n.t('footer').map do |attributes|
      metadata = NewPageGenerator.new(
        page_type: 'standalone',
        page_url: attributes[:url],
        page_uuid: SecureRandom.uuid
      ).to_metadata

      metadata.tap do
        metadata['heading'] = attributes[:heading]
        metadata['body'] = attributes[:body]
      end
    end
  end

  def default_form_flow_object(metadata)
    start_page_uuid = metadata['pages'][0]['_uuid']
    cya_page_uuid = metadata['pages'][1]['_uuid']
    confirmation_page_uuid = metadata['pages'][2]['_uuid']

    {
      start_page_uuid => {
        '_type': 'flow.page',
        'next': {
          'default': cya_page_uuid
        }
      },
      cya_page_uuid => {
        '_type': 'flow.page',
        'next': {
          'default': confirmation_page_uuid
        }
      },
      confirmation_page_uuid => {
        '_type': 'flow.page',
        'next': {
          'default': ''
        }
      }
    }
  end

  def add_cya_and_confirmation(metadata)
    cya_metadata = DefaultMetadata['page.checkanswers']
      .merge('_uuid' => SecureRandom.uuid)
      .merge('url' => 'check-answers')

    confirmation_metadata = DefaultMetadata['page.confirmation']
      .merge('_uuid' => SecureRandom.uuid)
      .merge('url' => 'form-sent')

    metadata['pages'].push(cya_metadata)
    metadata['pages'].push(confirmation_metadata)
    metadata['flow'].merge!(default_form_flow_object(metadata))

    metadata
  end
end
