module Admin
  class AnnouncementsController < Admin::ApplicationController
    # rubocop:disable Rails/LexicallyScopedActionFilter
    before_action :check_is_editable, only: %i[edit update]
    # rubocop:enable Rails/LexicallyScopedActionFilter

    def destroy
      if requested_resource.revoke!(current_user)
        flash[:notice] = 'Announcement was successfully revoked'
      else
        flash[:error] = requested_resource.errors.full_messages.join('<br/>')
      end

      redirect_to after_resource_destroyed_path(requested_resource)
    end

    private

    def check_is_editable
      unless requested_resource.editable?
        flash[:error] = 'This announcement is not editable'
        redirect_to after_resource_destroyed_path(requested_resource)
      end
    end

    def new_resource(params = {})
      super.tap do |announcement|
        announcement.created_by = current_user
        announcement.date_from ||= Date.current
      end
    end

    def default_sorting_attribute
      :created_at
    end

    def default_sorting_direction
      :desc
    end

    def records_per_page
      10
    end
  end
end
