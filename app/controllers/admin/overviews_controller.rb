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
          value: published('production').count
        },
        {
          name: 'Published to Test',
          value: published('dev').count
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
  end
end
