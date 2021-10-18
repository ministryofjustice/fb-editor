class AddVersionIdToPublishServices < ActiveRecord::Migration[6.1]
  def change
    add_column :publish_services, :version_id, :uuid
  end
end
