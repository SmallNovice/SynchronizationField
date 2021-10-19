class UpdateFormFieldsJob < ApplicationJob
  queue_as :default

  def perform(table_name, fields_sets, old_records_table_name)
    Sequelable.update_fields(table_name, fields_sets, old_records_table_name)
    Sequelable.old_field_records(:update, old_records_table_name, fields_sets)
  end
end
