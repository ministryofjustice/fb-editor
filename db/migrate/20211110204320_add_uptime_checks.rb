class AddUptimeChecks < ActiveRecord::Migration[6.1]
  def change
    create_table :uptime_checks do |t|
      t.uuid :service_id, :null => false
      t.string :check_id, :null => false

      t.timestamps
    end
    add_index :uptime_checks, :service_id
  end
end
