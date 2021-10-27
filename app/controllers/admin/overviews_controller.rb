module Admin
  class OverviewsController < Admin::ApplicationController
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
          value: published('production')
        },
        {
          name: 'Published to Test',
          value: published('dev')
        }
      ]
    end

    private

    def active_sessions
      cutoff_period = 90.minutes.ago
      ActiveRecord::SessionStore::Session.where(
        'updated_at < ?', cutoff_period
      ).count
    end

    def published(environment)
      PublishService.where(deployment_environment: environment)
                    .select('DISTINCT ON ("service_id") *')
                    .order(:service_id, created_at: :desc)
                    .select { |ps| ps.status == 'completed' }
                    .count
    end
  end
end
