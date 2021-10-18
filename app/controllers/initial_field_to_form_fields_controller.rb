class InitialFieldToFormFieldsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :get_fields

  def receive
    form_table_name = FormTableName.table_name(params[:form][:namespace_id], params[:form][:id])
    ole_records_table_name = FormTableName.ole_records_table_name(params[:form][:namespace_id], params[:form][:id])
    unless Sequelable.db_connect.table_exists?(form_table_name)
      CreateFormTableJob.perform_now(form_table_name, @fields_sets, ole_records_table_name)
    end
    CreateFormFieldsJob.perform_now(form_table_name, @fields_sets, ole_records_table_name)
    UpdateFormFieldsJob.perform_now(form_table_name, @fields_sets, ole_records_table_name)
    DropFormFieldsJob.perform_now(form_table_name, @fields_sets, ole_records_table_name)
  end

  private

  def get_fields
    @fields_sets = request.request_parameters[:form][:fields]
  end

end
