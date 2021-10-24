class MapperJob < ApplicationJob
  queue_as :default

  def perform(mapper_id, fields)
    mapper = TableMapper.find(mapper_id)

    table_name = FormTableName.table_name(mapper.namespace_id, mapper.mapper_id)
    records = FormTableName.table_name(mapper.namespace_id, mapper.mapper_id, :records)

    mapper.run(table_name, fields, records)
  end
end
