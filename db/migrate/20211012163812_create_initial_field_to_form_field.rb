class CreateInitialFieldToFormField < ActiveRecord::Migration[6.1]
  def change
    create_table :initial_field_to_form_fields do |t|
      t.string :company
      t.string :number

      t.timestamps
    end
  end
end
