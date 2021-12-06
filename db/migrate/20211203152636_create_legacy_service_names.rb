class CreateLegacyServiceNames < ActiveRecord::Migration[6.1]
  def change
    create_table :legacy_service_names do |t|
      t.string :name

      t.timestamps
    end
  end
end
