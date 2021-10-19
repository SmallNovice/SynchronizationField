class CreateFormTableJob < ApplicationJob
  queue_as :default

  def perform(table_name, fields_sets, old_records_table_name)
    Sequelable.create_form_table(table_name, fields_sets)
    Sequelable.old_field_records(:create, old_records_table_name, fields_sets)
  end
end
