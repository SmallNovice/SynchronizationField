class CreateTableMapper < ActiveRecord::Migration[6.1]
  def change
    create_table :table_mappers do |t|
      t.string :type
      t.string :action_type

      t.timestamps
    end
  end
end
