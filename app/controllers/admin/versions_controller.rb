module Admin
  class VersionsController < Admin::ApplicationController
    def show
      @version = MetadataApiClient::Version.find(
        service_id: params[:service_id],
        version_id: params[:id]
      )
      @version_creator = User.find(@version.metadata['created_by'])
    end
  end
end
