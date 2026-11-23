module Admin
  class VersionsController < Admin::ApplicationController
    before_action :version_and_user, except: [:update]

    def show; end

    def edit
      @service_id = params[:service_id]
    end

    def update
      previous_owner_id = MetadataApiClient::Service.latest_version(params[:service_id])['created_by']
      new_metadata = JSON.parse(params[:version])
      version = AdminMetadataVersion.new(
        service: OpenStruct.new(service_id: params[:service_id]),
        metadata: new_metadata
      ).create_version

      if version
        flash[:success] = 'Successfully updated metadata version'
        notify_of_update(params[:service_id])
        record_ownership_transfer_admin_event(previous_owner_id:, new_owner_id: new_metadata['created_by'])
        redirect_to admin_service_path(params[:service_id])
      else
        flash[:error] = 'Unable to update metadata version'
        redirect_to edit_admin_service_version_path(params[:service_id], params[:id])
      end
    end

    private

    def version_and_user
      @version = MetadataApiClient::Version.find(
        service_id: params[:service_id],
        version_id: params[:id]
      )
      @version_creator = User.find(@version.metadata['created_by'])
    end

    def record_ownership_transfer_admin_event(previous_owner_id:, new_owner_id:)
      return if previous_owner_id == new_owner_id

      AdminEvent.create!(
        user_id: current_user.id,
        service_id: params[:service_id],
        action: I18n.t(
          'settings.transfer_ownership.admin_event',
          previous_owner_email: owner_email(previous_owner_id),
          new_owner_email: owner_email(new_owner_id),
          locale: :en
        )
      )
    end

    def owner_email(user_id)
      User.find_by(id: user_id)&.email || user_id
    end

    def notify_of_update(service_id)
      if ENV['PLATFORM_ENV'] == 'live'
        NotificationService.notify(
          "Service ID #{service_id} has been updated using the Admin dashboard by #{current_user.name}"
        )
      end
    end
  end
end
