class InitialFieldToFormFieldsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :get_fields

  def receive
    CreateFormFieldsJob.perform_now(FormTableName.table_name, @fields_sets)
  end

  private

  def get_fields
    @fields_sets = request.request_parameters[:form][:fields]
  end

end
