class AddMapperIdToTableMapper < ActiveRecord::Migration[6.1]
  def change
    add_column :table_mappers, :mapper_id, :integer
  end
end
