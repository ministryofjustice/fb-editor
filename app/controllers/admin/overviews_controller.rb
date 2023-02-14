module Admin
  class OverviewsController < Admin::ApplicationController
    require 'csv'

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
          name: 'Pending jobs',
          value: Delayed::Job.where('attempts = 0').count
        },
        {
          name: 'Failed jobs',
          value: Delayed::Job.where('attempts > 0').count
        },
        {
          name: 'Published to Live',
          value: published('production').count
        },
        {
          name: 'Published to Test',
          value: published('dev').count
        }
      ]
    end

    def export_services
      @headers = ['Service name', 'User email', 'Published Test', 'Published Live']
      @services = services_to_export.sort_by { |s| s[:name] }

      response.headers['Content-Type'] = 'text/csv'
      response.headers['Content-Disposition'] = "attachment; filename=#{csv_filename}"
      render template: '/admin/overviews/export_services.csv.erb'
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
  end
end
