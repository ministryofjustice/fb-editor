class CreateAnnouncementDismissals < ActiveRecord::Migration[7.0]
  def change
    create_join_table :announcements, :users, column_options: { type: :uuid, null: false } do |t|
      t.index [:announcement_id, :user_id], unique: true
    end
  end
end
