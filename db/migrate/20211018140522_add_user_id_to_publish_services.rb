class AddUserIdToPublishServices < ActiveRecord::Migration[6.1]
  def change
    add_column :publish_services, :user_id, :uuid
    add_index :publish_services, :user_id
  end
end
