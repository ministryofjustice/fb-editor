module Api
  class AutocompleteController < ApiController
    before_action :assign_items

    def show
      render @items, layout: false
    end

    def create
      if @items.valid?

        response = MetadataApiClient::Items.create(
          service_id: params[:service_id],
          component_id: params[:component_id],
          created_by: service.created_by,
          data: items_hash(@items.file_values)
        )
        return head :created unless response.errors?

        response.errors.each do |error|
          @items.errors.add(:message, error)
        end
      end
      render_unprocessable_entity
    rescue ClamdscanError => e
      Rails.logger.warn("ClamdscanError message: #{e.message}")
      @items.errors.add(
        :message,
        I18n.t('activemodel.errors.models.autocomplete_items.scan_error')
      )
      render_unprocessable_entity
    end

    private

    def autocomplete_items_file
      @autocomplete_items_file ||= params.dig(:autocomplete_items, :file)
    end

    def base_params
      @base_params ||=
        {
          service_id: service.service_id,
          component_id: params[:component_id],
          file: autocomplete_items_file
        }
    end

    def items_hash(csv_items)
      csv_items.map do |r|
        {
          text: r[0],
          value: r[1].nil? ? r[0] : r[1]
        }
      end
    end

    def assign_items
      @items = AutocompleteItems.new(base_params)
    end

    def render_unprocessable_entity
      render partial: 'show', status: :unprocessable_entity, layout: false
    end
  end
end
