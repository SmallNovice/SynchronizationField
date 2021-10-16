module Sequelable
  extend ActiveSupport::Concern

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
