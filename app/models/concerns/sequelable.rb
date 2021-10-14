module Sequelable
  extend ActiveSupport::Concern

  def self.create_field(fields = {})
    db_connect.alter_table :initial_field_to_form_fields do
      fields.each do |k|
        if (InitialFieldToFormField.column_names & [k["identity_key"]]).blank?
          add_column :"#{k["identity_key"]}", String
        end
      end
    end
  end

  private

  def self.db_connect
    return @db if @db
    @db = Sequel.connect('sqlite://db/development.sqlite3')
  end
end
