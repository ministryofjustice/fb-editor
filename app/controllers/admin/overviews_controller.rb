module Admin
  class OverviewsController < Admin::ApplicationController
    require 'csv'
    ACCEPTANCE_TEST_USER_ID = 'a5833e7a-a210-4447-904c-df050d198e33'.freeze
    # new-runner-acceptance-tests and Acceptance Tests - Branching Fixture 10 service IDs
    # Save-and-return v2 - Conditional Content - API Submission JSON acceptance tests
    RUNNER_ACCEPTANCE_TEST_FORMS = %w[
      cd75ad76-1d4b-4ce5-8a9e-035262cd2683
      e68dca75-20b8-468e-9436-e97791a914c5
      759716eb-b4fb-413e-b883-f7016e2a9feb
      11744bdf-86e3-4be3-b2cc-86434dc08ef2
      1ef15479-5a2c-4426-a5bf-54253031d9be
    ].freeze

    def index
      @stats = [
        {
          name: 'Registered users',
          value: User.count
        },
        {
          name: 'Active sessions',
          value: active_sessions
        },
        {
          name: 'Currently Published to Live',
          value: published('production').reject { |p| moj_forms_team_service_ids.include?(p.service_id) }.count
        },
        {
          name: 'Currently Published to Test',
          value: published('dev').reject { |p| moj_forms_team_service_ids.include?(p.service_id) }.count
        },
        {
          name: 'Ever published to Live',
          value: ever_published('production').reject { |p| moj_forms_team_service_ids.include?(p.service_id) }.count
        },
        {
          name: 'Ever published to Test',
          value: ever_published('dev').reject { |p| moj_forms_team_service_ids.include?(p.service_id) }.count
        },
        {
          name: 'Awaiting approval for go live',
          value: ServiceConfiguration.where(name: 'AWAITING_APPROVAL').reject { |p| moj_forms_team_service_ids.include?(p.service_id) }.count
        }
      ]
    end

    def export_services
      respond_to do |format|
        format.csv do
          services = services_to_export.sort_by { |s| s[:name] }

          csv_data = CSV.generate do |csv|
            csv << ['Service name', 'User email', 'Published Test', 'Published Live', 'First Published']
            services.each do |service|
              csv << service.values.map(&:strip)
            end
          end

          send_data csv_data, filename: csv_filename, type: 'text/csv'
        end
      end
    end

    def export_dev_form_summary
      respond_to do |format|
        summary = service_summary('dev')

        format.csv do
          csv_data = CSV.generate do |csv|
            csv << ['Service id', 'Service name', 'Locale', 'Start pages', 'Confirmation pages', 'Check your answers pages', 'Standalone pages', 'Exit pages', 'Single Question pages', 'Multiple Question pages', 'Address components', 'Autocomplete components', 'Checkbox components', 'Content components', 'Date components', 'Email components', 'Upload components', 'Multiupload components', 'Number components', 'Radio components', 'Text input components', 'Textarea components', 'Confirmation email enabled', 'Save and return enabled', 'Collect data via email', 'Send to JSON api', 'Receive csv', 'External start page enabled', 'Analytics enabled', 'Reference number enabled', 'Payment link enabled']
            summary.each do |s|
              csv << to_csv_value(s)
            end
          end

          send_data csv_data, filename: 'dev_forms_summary.csv', type: 'text/csv'
        end
      end
    end

    def export_live_form_summary
      respond_to do |format|
        summary = service_summary('production')

        format.csv do
          csv_data = CSV.generate do |csv|
            csv << ['Service id', 'Service name', 'Locale', 'Start pages', 'Confirmation pages', 'Check your answers pages', 'Standalone pages', 'Exit pages', 'Single Question pages', 'Multiple Question pages', 'Address components', 'Autocomplete components', 'Checkbox components', 'Content components', 'Date components', 'Email components', 'Upload components', 'Multiupload components', 'Number components', 'Radio components', 'Text input components', 'Textarea components', 'Confirmation email enabled', 'Save and return enabled', 'Collect data via email', 'Send to JSON api', 'Receive csv', 'External start page enabled', 'Analytics enabled', 'Reference number enabled', 'Payment link enabled']
            summary.each do |s|
              csv << to_csv_value(s)
            end
          end

          send_data csv_data, filename: 'live_forms_summary.csv', type: 'text/csv'
        end
      end
    end

    private

    def to_csv_value(summary)
      result = []

      # rubocop:disable Style/ConditionalAssignment
      summary.each_value { |v| v.is_a?(Hash) ? result << v.values.map!(&:to_s) : result << v.to_s }
      # rubocop:enable Style/ConditionalAssignment

      result.flatten
    end

    def active_sessions
      cutoff_period = 90.minutes.ago
      ActiveRecord::SessionStore::Session.where(
        'updated_at < ?', cutoff_period
      ).count
    end

    def services_to_export
      User.all.each_with_object([]) do |user, array|
        # skip any services created by the acceptance tests user
        next if user.id == ACCEPTANCE_TEST_USER_ID

        MetadataApiClient::Service.all(user_id: user.id).find_all do |service|
          meta = service.metadata

          array << {
            name: meta['service_name'],
            user: user.email,
            published_test: published_state(meta['service_id'], 'dev'),
            published_live: published_state(meta['service_id'], 'production'),
            published_date: currently_published?(meta['service_id'], 'production') ? first_publish_date(meta['service_id'], 'production').strftime('%d/%m/%Y') : ''
          }
        end
      end
    end

    def service_summary(env)
      published_service_ids = published(env).reject { |p| moj_forms_team_service_ids.include?(p.service_id) }.map(&:service_id)
      result = []

      published_service_ids.each do |id|
        metadata = MetadataApiClient::Service.latest_version(id)
        result << {
          service_id: id,
          service_name: metadata['service_name'],
          locale: metadata['locale'],
          page_counts: page_type_counts(metadata['pages']),
          component_counts: component_type_counts(metadata['pages']),
          confirmation_email_enabled: ServiceConfiguration.find_by(service_id: id, deployment_environment: env, name: 'CONFIRMATION_EMAIL_COMPONENT_ID').present?,
          save_and_return_enabled: ServiceConfiguration.find_by(service_id: id, deployment_environment: env, name: 'SAVE_AND_RETURN').present?,
          collect_information_by_email_enabled: ServiceConfiguration.find_by(service_id: id, deployment_environment: env, name: 'SERVICE_EMAIL_BODY').present?,
          send_to_json_api_enabled: ServiceConfiguration.find_by(service_id: id, deployment_environment: env, name: 'SERVICE_OUTPUT_JSON_ENDPOINT').present?,
          receive_csv_enabled: ServiceConfiguration.find_by(service_id: id, deployment_environment: env, name: 'SERVICE_CSV_OUTPUT').present?,
          external_start_page_enabled: ServiceConfiguration.find_by(service_id: id, deployment_environment: 'production', name: 'EXTERNAL_START_PAGE_URL').present?,
          analytics_enabled: ServiceConfiguration.find_by(service_id: id, deployment_environment: env, name: 'GA4').present?,
          reference_number_enabled: ServiceConfiguration.find_by(service_id: id, deployment_environment: env, name: 'REFERENCE_NUMBER').present?,
          payment_link_enabled: ServiceConfiguration.find_by(service_id: id, deployment_environment: env, name: 'PAYMENT_LINK').present?
        }
      end

      result
    end

    def page_type_counts(pages)
      {
        start_pages: pages.select { |p| p['_type'] == 'page.start' }.count,
        confirmation_pages: pages.select { |p| p['_type'] == 'page.confirmation' }.count,
        checkanswers_pages: pages.select { |p| p['_type'] == 'page.checkanswers' }.count,
        singlequestion_pages: pages.select { |p| p['_type'] == 'page.singlequestion' }.count,
        multiplequestions_pages: pages.select { |p| p['_type'] == 'page.multiplequestions' }.count,
        exit_pages: pages.select { |p| p['_type'] == 'page.exit' }.count,
        standalone_pages: pages.select { |p| p['_type'] == 'page.standalone' }.count
      }
    end

    def component_type_counts(pages)
      addresses = 0
      autocompletes = 0
      checkboxes = 0
      contents = 0
      dates = 0
      emails = 0
      uploads = 0
      multiuploads = 0
      numbers = 0
      radios = 0
      texts = 0
      textareas = 0

      pages.each do |page|
        next if page['components'].blank?

        addresses += page['components'].select { |c| c['_type'] == 'address' }.count
        autocompletes += page['components'].select { |c| c['_type'] == 'autocomplete' }.count
        checkboxes += page['components'].select { |c| c['_type'] == 'checkboxes' }.count
        contents += page['components'].select { |c| c['_type'] == 'content' }.count
        dates += page['components'].select { |c| c['_type'] == 'date' }.count
        emails += page['components'].select { |c| c['_type'] == 'email' }.count
        uploads += page['components'].select { |c| c['_type'] == 'upload' }.count
        multiuploads += page['components'].select { |c| c['_type'] == 'multiupload' }.count
        numbers += page['components'].select { |c| c['_type'] == 'number' }.count
        radios += page['components'].select { |c| c['_type'] == 'radios' }.count
        texts += page['components'].select { |c| c['_type'] == 'text' }.count
        textareas += page['components'].select { |c| c['_type'] == 'textarea' }.count
      end

      {
        addresses:, autocompletes:, checkboxes:, contents:, dates:, emails:, uploads:, multiuploads:, numbers:, radios:, texts:, textareas:
      }
    end

    def published_state(service_id, environment)
      currently_published?(service_id, environment) ? 'Yes' : 'No'
    end

    def currently_published?(service_id, environment)
      PublishService.where(
        service_id:,
        deployment_environment: environment
      ).last&.published?
    end

    def first_publish_date(service_id, environment)
      PublishService.where(
        service_id:,
        deployment_environment: environment
      ).published.first&.created_at
    end

    def csv_filename
      "#{ENV['PLATFORM_ENV']}-services-#{Time.zone.now.strftime('%Y-%m-%d')}.csv"
    end

    def moj_forms_team_service_ids
      @moj_forms_team_service_ids ||= team_services.map(&:id) + RUNNER_ACCEPTANCE_TEST_FORMS
    end

    def team_services
      user_ids.map { |id| MetadataApiClient::Service.all(user_id: id) }.flatten
    end

    def user_ids
      User.all.map { |user| user.id if user.email.in?(team_emails) }.compact.push(ACCEPTANCE_TEST_USER_ID)
    end

    def team_emails
      @team_emails ||= Rails.application.config.moj_forms_team
    end
  end
end
