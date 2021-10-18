class CreateFormFieldsJob < ApplicationJob
  queue_as :default

  def perform(table_name, fields_sets, ole_records_table_name)
    Sequelable.create_field(table_name, fields_sets, ole_records_table_name)
    Sequelable.old_field_records("create", ole_records_table_name, fields_sets)
  end
end

