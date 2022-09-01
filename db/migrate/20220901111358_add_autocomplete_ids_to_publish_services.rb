class AddAutocompleteIdsToPublishServices < ActiveRecord::Migration[6.1]
  def change
    add_column :publish_services, :autocomplete_ids, :uuid, array: true, default: []
  end
end
