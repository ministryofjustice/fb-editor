class AnnouncementsController < PermissionsController
  skip_before_action :authorised_access, only: %i[dismiss]

  def dismiss
    announcement = Announcement.find(params[:id])
    announcement.dismiss!(current_user)

    render turbo_stream: turbo_stream.remove(
      AnnouncementComponent::TURBO_FRAME_ID
    )
  end
end
