class CreateFormTableJob < ApplicationJob
  queue_as :default

  def perform(table_name, fields_sets)
    Sequelable.create_form_table(table_name, fields_sets)
  end
end
