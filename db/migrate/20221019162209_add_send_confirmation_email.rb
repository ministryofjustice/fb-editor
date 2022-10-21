class AddSendConfirmationEmail < ActiveRecord::Migration[6.1]
  def change
    add_column :submission_settings, :send_confirmation_email, :boolean, default: false
  end
end
