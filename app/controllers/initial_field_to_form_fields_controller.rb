class InitialFieldToFormFieldsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :get_fields

  def receive
    form_table_name = FormTableName.table_name(params[:form][:namespace_id], params[:form][:id])
    
    record_data_table_name = FormTableName.record_data_table_name(params[:form][:namespace_id], params[:form][:id])

    FormUpdateJob.perform_later(form_table_name, @fields_sets, record_data_table_name)
  end

  private

  def get_fields
    @fields_sets = request.request_parameters[:form][:fields]
  end

end
