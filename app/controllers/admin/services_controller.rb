module Admin
  class ServicesController < Admin::ApplicationController
    include MetadataVersionHelper

    def index
      response = MetadataApiClient::Service.all_services(
        page:,
        per_page:,
        name_query: params[:search] || ''
      )

      @services = Kaminari.paginate_array(
        response[:services],
        total_count: response[:total_services]
      ).page(page).per(per_page)
    end

    def show
      @latest_metadata = MetadataApiClient::Service.latest_version(params[:id])
      @service = MetadataPresenter::Service.new(@latest_metadata, editor: true)
      @service_creator = User.find(@service.created_by)
      @version_creator = version_creator
      @published_to_live = published('production')
      @published_to_test = published('dev')
      @versions = MetadataApiClient::Version.all(@service.service_id)
    end

    def create
      original_metadata = latest_version(params[:service_id])
      duplicate_name =  "#{original_metadata['service_name']} - COPY"
      service_creation = ServiceCreation.new(
        service_name: duplicate_name,
        current_user:
      )

      if service_creation.create
        duplicate_version = AdminMetadataVersion.new(
          service: OpenStruct.new(service_id: service_creation.service_id),
          metadata: original_metadata.merge(duplicate_attributes(service_creation))
        ).create_version

        if duplicate_version
          flash[:success] = "#{service_creation.service_name} duplicate successfully created"
        else
          flash[:error] = service_creation.errors.full_messages.join("\n")
        end
      else
        flash[:error] = if name_taken?(service_creation)
                          "'#{original_metadata['service_name']}' has already been duplicated"
                        else
                          service_creation.errors.full_messages.join("\n")
                        end
      end

      redirect_to admin_services_path
    end

    def edit
      @latest_metadata = MetadataApiClient::Service.latest_version(params[:id])
      @service = MetadataPresenter::Service.new(@latest_metadata, editor: true)

      @maintenance_mode_settings = MaintenanceModeSettings.new(
        service_id: @service.service_id,
        deployment_environment: 'production'
      )
    end

    def update
      @latest_metadata = MetadataApiClient::Service.latest_version(params[:id])
      @service = MetadataPresenter::Service.new(@latest_metadata, editor: true)

      @maintenance_mode_settings = MaintenanceModeSettings.new(
        maintenance_mode_params.merge(service_id: @service.service_id, deployment_environment: 'production')
      )

      if @maintenance_mode_settings.valid?
        MaintenanceModeSettingsUpdater.new(
          settings: @maintenance_mode_settings,
          service_id: @service.service_id
        ).create_or_update!

        redirect_to admin_services_path
      else
        render action: 'edit'
      end
    end

    def unpublish
      if queued?
        flash[:notice] = "Already queued for unpublishing from #{params[:deployment_environment]}"
      else
        publish_service = PublishService.find(params[:publish_service_id])
        version_metadata = get_version_metadata(publish_service)
        publish_service_creation = PublishServiceCreation.new(
          service_id: publish_service.service_id,
          version_id: version_metadata['version_id'],
          deployment_environment: params[:deployment_environment],
          user_id: current_user.id
        )
        if publish_service_creation.save
          UnpublishServiceJob.perform_later(
            publish_service_id: publish_service_creation.publish_service_id,
            service_slug: service_slug(publish_service.service_id, version_metadata)
          )
          flash[:success] = "Service queued for unpublishing from #{params[:deployment_environment]}. Refresh in a minute"
        else
          flash[:error] = @publish_service_creation.errors.full_messages.join("\n")
        end
      end

      service_id = publish_service&.service_id || params[:service_id]
      redirect_to admin_service_path(service_id)
    end

    def republish
      if queued?
        flash[:notice] = "Already queued for republishing from #{params[:deployment_environment]}"
      else
        publish_service = PublishService.find(params[:publish_service_id])
        version_metadata = get_version_metadata(publish_service)
        publish_service_creation = PublishServiceCreation.new(
          service_id: publish_service.service_id,
          version_id: version_metadata['version_id'],
          user_id: current_user.id,
          deployment_environment: params[:deployment_environment],
          require_authentication:,
          username:,
          password:
        )
        if publish_service_creation.save
          PublishServiceJob.perform_later(
            publish_service_id: publish_service_creation.publish_service_id
          )
          flash[:success] = "Service queued for re-publishing to #{params[:deployment_environment]}. Re-publishing version: #{version_metadata['version_id']}. Refresh in a minute"
        else
          flash[:error] = @publish_service_creation.errors.full_messages.join("\n")
        end
      end

      service_id = publish_service&.service_id || params[:service_id]
      redirect_to admin_service_path(service_id)
    end

    def search_term
      params[:search] || ''
    end
    helper_method :search_term

    private

    def version_creator
      if @service_creator.id == @latest_metadata['created_by']
        @service_creator
      else
        User.find(@latest_metadata['created_by'])
      end
    end

    def published(environment)
      return {} if unpublished?(environment)

      publish_service = PublishService.where(
        service_id: @service.service_id,
        deployment_environment: environment
      ).completed.desc.first

      return {} if publish_service.nil?

      {
        id: publish_service.id,
        published_by: published_by(publish_service.user_id)&.name,
        created_at: publish_service.created_at,
        version_id: publish_service.version_id
      }
    end

    def published_by(user_id)
      return @service_creator if user_id == @service_creator&.id

      return @version_creator if user_id == @version_creator&.id

      User.find_by(id: user_id)
    end

    def duplicate_attributes(service_creation)
      {
        'service_name' => service_creation.service_name,
        'service_id' => service_creation.service_id,
        'created_by' => current_user.id
      }
    end

    def name_taken?(service_creation)
      service_creation.errors.first.type == :taken
    end

    def page
      @page ||= params[:page] || 1
    end

    def per_page
      params[:per_page] || 20
    end

    def queued?
      publish_service = PublishService.where(
        service_id: params[:service_id],
        deployment_environment: params[:deployment_environment]
      ).last
      publish_service.queued? || publish_service.unpublishing?
    end

    def unpublished?(environment)
      PublishService.where(
        service_id: @service.service_id,
        deployment_environment: environment
      ).last&.unpublished?
    end

    def maintenance_mode_params
      params.require(:maintenance_mode_settings).permit(
        :maintenance_mode,
        :maintenance_page_heading,
        :maintenance_page_content
      )
    end

    def username
      @username ||= ServiceConfiguration.find_by(
        service_id: params[:service_id],
        deployment_environment: params[:deployment_environment],
        name: 'BASIC_AUTH_USER'
      )&.decrypt_value
    end

    def password
      @password ||= ServiceConfiguration.find_by(
        service_id: params[:service_id],
        deployment_environment: params[:deployment_environment],
        name: 'BASIC_AUTH_PASS'
      )&.decrypt_value
    end

    def require_authentication
      password.present? && username.present? ? '1' : '0'
    end

    def service_slug_config(service_id)
      ServiceConfiguration.find_by(
        service_id:,
        name: 'SERVICE_SLUG',
        deployment_environment: 'dev'
      )&.decrypt_value
    end

    def service_slug_from_name(version_metadata)
      service = MetadataPresenter::Service.new(version_metadata, editor: true)
      service.service_slug
    end

    def service_slug(service_id, version_metadata)
      service_slug_config(service_id).presence || service_slug_from_name(version_metadata)
    end
  end
end
