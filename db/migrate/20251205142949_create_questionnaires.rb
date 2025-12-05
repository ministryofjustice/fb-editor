class CreateQuestionnaires < ActiveRecord::Migration[7.2]
  def change
    create_table :questionnaires do |t|
      t.string :reason_for_creating_form, null: false
      t.boolean :govuk_forms_ruled_out, null: false
      t.jsonb :required_moj_forms_features, null: false
      t.text :govuk_forms_explanation
      t.boolean :continue_with_moj_forms, null: false
      t.string :estimated_page_count, null: false
      t.string :estimated_first_year_submissions, null: false
      t.string :submission_delivery_method, null: false
      t.references :service, null: false, foreign_key: true

      t.timestamps
    end
  end
end
