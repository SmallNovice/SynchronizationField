class MapperJob < ApplicationJob
  queue_as :default

  def perform(mapper_id)
    mapper = TableMapper.find(mapper_id)

    table_name = FormTableName.table_name(mapper.namespace_id, mapper.mapper_id)
    records = FormTableName.table_name(mapper.namespace_id, mapper.mapper_id, :records)
    fields = mapper.fields
    
    sequelable = Sequelable.new(table_name, fields, records)

    mapper.run(sequelable)
  end
end
