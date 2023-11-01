module Admin
  class OverviewsController < Admin::ApplicationController
    require 'csv'
    # new-runner-acceptance-tests and Acceptance Tests - Branching Fixture 10 service IDs
    RUNNER_ACCEPTANCE_TEST_FORMS = %w[
      cd75ad76-1d4b-4ce5-8a9e-035262cd2683
      e68dca75-20b8-468e-9436-e97791a914c5
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
          value: published('production').reject { |p| moj_forms_team_service_ids.include?(p.service_id) }.select(&:published?).count
        },
        {
          name: 'Currently Published to Test',
          value: published('dev').reject { |p| moj_forms_team_service_ids.include?(p.service_id) }.select(&:published?).count
        },
        {
          name: 'Ever published to Live',
          value: published('production').reject { |p| moj_forms_team_service_ids.include?(p.service_id) }.count
        },
        {
          name: 'Ever published to Test',
          value: published('dev').reject { |p| moj_forms_team_service_ids.include?(p.service_id) }.count
        }
      ]
    end

    def export_services
      respond_to do |format|
        format.csv do
          @headers = ['Service name', 'User email', 'Published Test', 'Published Live']
          @services = services_to_export.sort_by { |s| s[:name] }

          response.headers['Content-Type'] = 'text/csv'
          response.headers['Content-Disposition'] = "attachment; filename=#{csv_filename}"
          render '/admin/overviews/export_services'
        end
      end
    end

    private

    def active_sessions
      cutoff_period = 90.minutes.ago
      ActiveRecord::SessionStore::Session.where(
        'updated_at < ?', cutoff_period
      ).count
    end

    def services_to_export
      User.all.each_with_object([]) do |user, array|
        # skip any services created by the acceptance tests user
        next if user.id == 'a5833e7a-a210-4447-904c-df050d198e33'

        MetadataApiClient::Service.all(user_id: user.id).each do |service|
          meta = service.metadata

          array << {
            name: meta['service_name'],
            user: user.email,
            published_test: published_state(meta['service_id'], 'dev'),
            published_live: published_state(meta['service_id'], 'production')
          }
        end
      end
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
      User.all.map { |user| user.id if user.email.in?(team_emails) }.compact
    end

    def team_emails
      @team_emails ||= Rails.application.config.moj_forms_team
    end
  end
end
