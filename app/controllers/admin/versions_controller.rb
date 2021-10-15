module Admin
  class AdminMetadataVersion
    include ActiveModel::Model
    include MetadataVersion
    attr_accessor :service, :metadata
  end

  class VersionsController < Admin::ApplicationController
    before_action :version_and_user, except: [:update]

    def show; end

    def edit
      @service_id = params[:service_id]
    end

    def update
      version = AdminMetadataVersion.new(
        service: service,
        metadata: JSON.parse(params[:version])
      ).create_version

      if version
        flash[:success] = 'Successfully updated metadata version'
      else
        flash[:error] = 'Unable to update metadata version'
      end

      redirect_to edit_admin_service_version_path(params[:service_id], params[:id])
    end

    private

    def version_and_user
      @version = MetadataApiClient::Version.find(
        service_id: params[:service_id],
        version_id: params[:id]
      )
      @version_creator = User.find(@version.metadata['created_by'])
    end

    def service
      # :P
      # Coz we are including MetadataVersion
      OpenStruct.new(service_id: params[:service_id])
    end
  end
end
