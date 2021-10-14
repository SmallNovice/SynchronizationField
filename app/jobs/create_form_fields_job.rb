class CreateFormFieldsJob < ApplicationJob
  queue_as :default

  def perform(table_name, fields_sets)
    Sequelable.create_field(table_name, fields_sets)
  end
end

