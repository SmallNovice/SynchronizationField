module FormTableName
  extend ActiveSupport::Concern

  def self.table_name(namespace_id = 14, mapperable_id = 13050)
    "form_#{namespace_id}_#{mapperable_id}".to_sym
  end
end
