module Admin
  class VersionsController < Admin::ApplicationController
    before_action :version_and_user, except: [:update]

    def show; end

    def edit
      @service_id = params[:service_id]
    end

    def update
      version = AdminMetadataVersion.new(
        service: OpenStruct.new(service_id: params[:service_id]),
        metadata: JSON.parse(params[:version])
      ).create_version

      if version
        flash[:success] = 'Successfully updated metadata version'
        notify_of_update(params[:service_id])
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

    def notify_of_update(service_id)
      if ENV['PLATFORM_ENV'] == 'live'
        NotificationService.notify(
          "Service ID #{service_id} has been updated using the Admin dashboard by #{current_user.name}"
        )
      end
    end
  end
end
