class TableMappersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :get_fields, :set_table_mapper

  def receive
    case @table_mapper.action_type
    when 'updated'
      MapperJob.perform_later(@table_mapper.id, @fields_sets)
      head :ok
    when 'destroyed'
      MapperJob.perform_later(@table_mapper.id, @fields_sets)
      head :ok
    end
  end

  private

  def get_fields
    @fields_sets = request.request_parameters[:form][:fields]
  end

  def set_table_mapper
    return if (@table_mapper = TableMapper.find_by(mapper_id: request.request_parameters[:form][:id])) && @table_mapper.action_type == request.request_parameters[:action]
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

    @table_mapper.save
  end

end
