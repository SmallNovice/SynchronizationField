module Sequelable
  extend ActiveSupport::Concern

  def self.create_form_table(table_name, fields = {}, record_data_table_name)
    return if table_exists?(table_name)

    db_connect.create_table table_name do
      primary_key :id
      DateTime :created_at
      DateTime :updated_at
      fields.each do |field|
        String "#{field[:identity_key]}"
      end
    end
    field_data_records(:create, record_data_table_name, fields)
  end

  def self.create_field(table_name, fields = {}, record_data_table_name)
    return unless table_exists?(table_name)

    table_fields = @db[record_data_table_name].all.map { |field| field[:field_id] }
    @db.alter_table table_name do
      fields.each do |field|

        if (@db[table_name].columns & [:"#{field[:identity_key]}"]).blank? && (table_fields & ["#{field[:id]}".to_i]).blank?
          add_column "#{field[:identity_key]}", String
        end
      end
    end
    field_data_records(:create, record_data_table_name, fields)
  end

  def self.update_fields(table_name, fields = {}, record_data_table_name)
    return unless table_exists?(table_name)

    db_connect.alter_table table_name do
      fields.each do |field|
        unless @db[record_data_table_name].where(field_id: field[:id]).all[0][:identity_key] == field[:identity_key]
          rename_column @db[record_data_table_name].where(field_id: field[:id]).all[0][:identity_key].to_sym, "#{field[:identity_key]}".to_sym
        end
      end
    end
    field_data_records(:update, record_data_table_name, fields)
  end

  def self.drop_field(table_name, fields, record_data_table_name)
    return unless table_exists?(table_name)

    table_fields = fields.map { |field| field[:identity_key] }

    db_connect.alter_table table_name do
      @db[table_name].columns.each do |database_columns_field|
        next if table_fields.include?(database_columns_field.to_s) || database_columns_field == :id || database_columns_field == :created_at || database_columns_field == :updated_at
        drop_column database_columns_field
      end
    end
    field_data_records(:delete, record_data_table_name, fields)
  end

  def self.field_records_create(record_data_table_name, fields = {})
    fields.each do |field|
      if db_connect[record_data_table_name].where(field_id: field[:id]).blank?
        db_connect[record_data_table_name].insert(field_id: field["id"], identity_key: "#{field["identity_key"]}")
      end
    end
  end

  def self.field_records_update(record_data_table_name, fields = {})
    fields.each do |field|
      unless db_connect[record_data_table_name].where(field_id: field[:id]).all[0][:identity_key].to_sym == field[:identity_key]
        db_connect[record_data_table_name].where(field_id: field['id']).update(identity_key: "#{field["identity_key"].to_s}")
      end
    end
  end

  def self.field_records_delete(record_data_table_name, fields = {})
    table_fields = fields.map { |field| field['id'] }

    db_connect[record_data_table_name].all.each do |database_columns_field|
      next if table_fields.include?(database_columns_field[:field_id])
      db_connect[record_data_table_name].where(field_id: database_columns_field[:field_id]).delete
    end
  end

  def self.field_data_records(status, record_data_table_name, fields = {})
    create_form_data_records(record_data_table_name)
    case status
    when :create
      field_records_create(record_data_table_name, fields)
    when :update
      field_records_update(record_data_table_name, fields)
    when :delete
      field_records_delete(record_data_table_name, fields)
    end
  end

  def self.create_form_data_records(record_data_table_name)
    return if table_exists?(record_data_table_name)

    db_connect.create_table record_data_table_name do
      primary_key :id
      Integer :field_id
      String :identity_key
    end
  end

  def self.db_connect
    @db ||= Sequel.connect('sqlite://db/development.sqlite3')
  end

  def self.table_exists?(table_name)
    db_connect.table_exists?(table_name)
  end
end
