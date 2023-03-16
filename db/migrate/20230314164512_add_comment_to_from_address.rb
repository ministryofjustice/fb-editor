class AddCommentToFromAddress < ActiveRecord::Migration[6.1]
  def change
    change_table_comment :from_addresses,  from: "", to: "DEPRECATED: We have kept the table to ensure backwards compatibility."
  end
end
