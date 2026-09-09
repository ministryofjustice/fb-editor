class AddSendToGraphApiToSubmissionSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :submission_settings, :send_to_graph_api, :boolean
  end
end
