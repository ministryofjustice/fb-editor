class CreateFromAddresses < ActiveRecord::Migration[6.1]
  def change
    create_table :from_addresses do |t|
      t.uuid :service_id, null: false
      t.string :email, null: false
      t.integer :status, default: 0

      t.timestamps
    end

    add_index :from_addresses, :service_id
  end
end
