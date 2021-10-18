class DropFormFieldsJob < ApplicationJob
  queue_as :default

  def perform(table_name, fields_sets, ole_records_table_name)
    Sequelable.drop_field(table_name, fields_sets)
    Sequelable.old_field_records("delete", ole_records_table_name, fields_sets)
  end
end
