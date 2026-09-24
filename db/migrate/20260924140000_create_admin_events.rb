class CreateAdminEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :admin_events, id: :uuid do |t|
      t.uuid :user_id
      t.string :action, null: false
      t.datetime :created_at, null: false
    end

    add_index :admin_events, :user_id
  end
end
