class RemoveLegacyServiceNames < ActiveRecord::Migration[7.0]
  def change
    drop_table :legacy_service_names
  end
end
