module Api
  class MultiuploadController < ApiController
    helper_method :has_error
    def show
      component
      @page_id = params['page_id']
      render partial: 'show', layout: false
    end

    def create
      @metadata_updater = PageUpdater.new(update_params)
      if(params['max_files_value'].to_i > 0)
        if @metadata_updater.update
          redirect_to edit_page_path(
            service.service_id,
            params['component']['page_uuid'],
            anchor: @metadata_updater.component_added.try(:id)
          ) and return
        else
          # @page.errors.add(:base, :unprocessable)
          render :edit, status: :unprocessable_entity and return
        end
      end
      redirect_to api_service_multiupload_path(service.service_id, params['page_id'], params['component_id']), status: :bad_request
      # render partial: 'show', layout: false, status: :bad_request, locals: { 'page_id' => params['page_id'], 'component_id' => params['component_id'] } and return
    end

    def has_error
      # byebug
    end

    def update_params
      page = service.pages.select{ |p| p._uuid == params['page_id']}.first.deep_dup
      page.metadata.components.select {|c| c['_uuid'] == params['component_id']}.first['max_files'] = params['max_files_value']
      page.component['max_files'] = params['max_files_value']
      update_params = ActiveSupport::HashWithIndifferentAccess.new({
        uuid: params['component']['page_uuid'],
        latest_metadata: service_metadata,
        service_id: service.service_id,
        actions: {},
      }).merge(page.to_h)
    end

    private

    def component
      @component ||= service.pages.select{ |p| p._uuid == params['page_id']}.first.components.select {|c| c._uuid == params['component_id']}.first
    end
  end
end