class AddNamespaceIdToTableMapper < ActiveRecord::Migration[6.1]
  def change
    add_column :table_mappers, :namespace_id, :integer
  end
end
