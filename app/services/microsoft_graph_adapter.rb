class MicrosoftGraphAdapter
  attr_accessor :site_id, :root_graph_url, :service, :env

  def initialize(root_graph_url: 'https://graph.microsoft.com/v1.0/', site_id: ENV['MS_SITE_ID'], service: nil, env: 'test')
    @root_graph_url = root_graph_url
    @site_id = site_id
    @service = service
    @env = env
  end

  def post_list_columns
    uri = URI.parse("#{root_graph_url}/sites/#{site_id}/lists/")

    connection ||= Faraday.new(uri) do |conn|
    end
    body = {
      'displayName' => "#{service.service_name} - #{env == 'dev' ? 'test' : 'live'} - #{service.version_id}",
      'columns' => column_headings,
      'list' => {
        'template' => nil
      }
    }

    connection.post do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "Bearer #{get_auth_token}"
      req.body = body.to_json
    end
  end

  def create_drive(drive_id)
    uri = URI.parse("#{root_graph_url}/sites/#{site_id}/drive/items/root/children")

    connection ||= Faraday.new(uri) do |conn|
    end

    body = {
      'name' => drive_id,
      'folder' => {}
    }

    connection.post do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "Bearer #{get_auth_token}"
      req.body = body.to_json
    end
  end

  def get_auth_token
    response = auth_connection.post do |req|
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      req.body = URI.encode_www_form(form_data)
    end

    response_body = JSON.parse(response.body)

    response_body['access_token']
  end

  def auth_connection
    @auth_connection ||= Faraday.new(URI.parse(auth_url)) do |conn|
      conn.response :raise_error
      conn.request :multipart
      conn.request :url_encoded
      conn.adapter :net_http
    end
  end

  def form_data
    {
      client_id: admin_app,
      client_secret: admin_secret,
      grant_type: 'client_credentials',
      resource: 'https://graph.microsoft.com/'
    }
  end

  def admin_app
    ENV['MS_ADMIN_APP_ID']
  end

  def admin_secret
    ENV['MS_ADMIN_APP_SECRET']
  end

  def auth_url
    ENV['MS_OAUTH_URL']
  end

  def column_headings
    components = []

    service.pages.each do |page|
      next unless page.components

      page_label = page['heading'] || page['lede']

      page.components.each do |component|
        next if component['_type'] == 'content'

        components << {
          'name' => Digest::MD5.hexdigest(component['name']).tr('0-9', ''),
          'displayName' => "#{display_name_for(component, page_label)} from #{page.url}",
          'text' =>
          {
            "allowMultipleLines": true,
            "appendChangesToExistingText": false,
            "linesForEditing": 6,
            "maxLength": 10_000,
            "textType": 'richText'
          }
        }
      end
    end

    components.insert(0,
                      {
                        'name' => Digest::MD5.hexdigest('Submission ID').tr('0-9', ''),
                        'displayName' => 'Submission ID',
                        'text' => {}
                      })
    components.insert(1,
                      {
                        'name' => Digest::MD5.hexdigest('Reference Number').tr('0-9', ''),
                        'displayName' => 'Reference Number',
                        'text' => {}
                      })

    components
  end

  def display_name_for(component, page_label)
    if %w[radios checkboxes].include?(component['_type'])
      component['legend'] || page_label # use the page label or legend if it's a checkbox component
    else
      component['label'] || component['legend'] || component['lede'] || page_label || '' # autocomplete has a legend not a label
    end
  end
end
