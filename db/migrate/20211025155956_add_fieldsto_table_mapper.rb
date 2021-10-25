class AddFieldstoTableMapper < ActiveRecord::Migration[6.1]
  def change
    add_column :table_mappers, :fields, :text
  end
end
