class CreateAnnouncements < ActiveRecord::Migration[7.0]
  def change
    create_table :announcements, id: :uuid do |t|
      t.timestamps
      t.datetime :revoked_at

      t.references :created_by, index: true, type: :uuid, foreign_key: { to_table: :users }, null: false
      t.references :revoked_by, index: true, type: :uuid, foreign_key: { to_table: :users }

      t.string :title, null: false
      t.text :content, null: false

      t.date :date_from, null: false
      t.date :date_to
    end
  end
end
