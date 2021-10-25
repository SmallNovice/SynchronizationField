class DropInitialFieldToFormFields < ActiveRecord::Migration[6.1]
  def change
    drop_table :initial_field_to_form_fields
  end
end
