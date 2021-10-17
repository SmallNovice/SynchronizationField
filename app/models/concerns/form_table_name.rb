module FormTableName
  extend ActiveSupport::Concern

  def self.table_name(namespace_id, mapperable_id)
    "form_#{namespace_id}_#{mapperable_id}".to_sym
  end

  def self.ole_records_table_name(namespace_id, mapperable_id)
    "form_#{namespace_id}_#{mapperable_id}_table_name_records".to_sym
  end
end
