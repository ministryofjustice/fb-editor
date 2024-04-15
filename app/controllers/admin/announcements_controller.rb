module Admin
  class AnnouncementsController < Admin::ApplicationController
    def destroy
      if requested_resource.revoke!(current_user)
        flash[:notice] = 'Announcement was successfully revoked'
      else
        flash[:error] = requested_resource.errors.full_messages.join('<br/>')
      end

      redirect_to after_resource_destroyed_path(requested_resource)
    end

    private

    def new_resource(params = {})
      super.tap do |announcement|
        announcement.created_by = current_user
        announcement.date_from ||= Date.current
      end
    end

    def after_resource_created_path(_requested_resource)
      { action: :index }
    end

    def default_sorting_attribute
      :created_at
    end

    def default_sorting_direction
      :desc
    end
  end
end
