class FormTableJob < ApplicationJob
  queue_as :default

  def perform(table_name, fields_sets, record_data_table_name)
    Sequelable.create_form_table(table_name, fields_sets, record_data_table_name)
    Sequelable.create_field(table_name, fields_sets, record_data_table_name)
    Sequelable.update_fields(table_name, fields_sets, record_data_table_name)
    Sequelable.drop_field(table_name, fields_sets, record_data_table_name)
  end
end


