class UpdataFormFields < ApplicationJob
  queue_as :default

  def perform(table_name, fields_sets)
    Sequelable.updata_fields(table_name, fields_sets)
  end
end
