class AddServiceCsvOutput < ActiveRecord::Migration[6.1]
  def change
    add_column :submission_settings, :service_csv_output, :boolean, default: false
  end
end
