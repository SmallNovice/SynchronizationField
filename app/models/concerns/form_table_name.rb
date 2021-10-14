module FormTableName
  extend ActiveSupport::Concern

  def self.table_name(namespace_id = 14, mapperable_id = 13050)
    if namespace_id == 14 && mapperable_id == 13050
      InitialFieldToFormField.table_name.to_sym
    else
      "form_#{namespace_id}_#{mapperable_id}".to_sym
    end
  end
end
