class TableMappersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_table_mapper

  def receive
    case @table_mapper.action_type
    when 'updated'
      MapperJob.perform_now(@table_mapper.id)
      head :ok
    when 'destroyed'
      MapperJob.perform_now(@table_mapper.id)
      head :ok
    end
  end

  private

  def set_table_mapper
    @table_mapper = TableMapper.new
    case request.request_parameters[:action]
    when 'updated'
      @table_mapper.type = 'TableMapper::TableMapperUpdater'
    when 'destroyed'
      @table_mapper.type = 'TableMapper::TableMapperDeleter'
    end

    @table_mapper.action_type = request.request_parameters[:action]
    @table_mapper.mapper_id = request.request_parameters[:form][:id]
    @table_mapper.namespace_id = request.request_parameters[:namespace_gid].split('/').last.to_i
    @table_mapper.fields = request.request_parameters[:form][:fields]
    @table_mapper.save
  end

end
