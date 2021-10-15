module Sequelable
  extend ActiveSupport::Concern

  def self.create_field(table_name, fields = {})
    db_connect.alter_table table_name do
      fields.each do |k|
        if (InitialFieldToFormField.column_names & [k[:identity_key]]).blank?
          add_column :"#{k[:identity_key]}", String
        end
      end
    end
  end

  def self.create_form_table(table_name, fields = {})
    return if table_exists?(table_name)

    db_connect.create_table table_name do
      primary_key :id
      DateTime :created_at
      fields.each do |k|
        String "#{k[:identity_key]}"
      end
    end
  end

  private

  def self.db_connect
    return @db if @db
    @db = Sequel.connect('sqlite://db/development.sqlite3')
  end

  def self.table_exists?(table_name)
    db_connect.table_exists?(table_name)
  end
end
