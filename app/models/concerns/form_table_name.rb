module FormTableName
  extend ActiveSupport::Concern

  def self.table_name(namespace_id, mapper_id, status = :form_table)
    case status
    when :form_table
      "form_#{namespace_id}_#{mapper_id}".to_sym
    when :records
      "form_#{namespace_id}_#{mapper_id}_table_name_records".to_sym
    end
  end

end
