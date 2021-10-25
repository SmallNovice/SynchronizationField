class Sequelable < ApplicationJob

  def initialize(table_name, fields = {}, records)
    @@table_name = table_name
    @@fields = fields
    @@records = records
  end
  
  def create_form_table
    return if table_exists?(@@table_name)

    db_connect.create_table @@table_name do
      primary_key :id
      DateTime :created_at
      DateTime :updated_at

      @@fields.each do |field|
        String "#{field[:identity_key]}"
      end
    end
    data_records(:create)
  end

  def create_fields
    return unless table_exists?(@@table_name)

    table_fields = @db[@@records].all.map { |field| field[:field_id] }

    @db.alter_table @@table_name do
      @@fields.each do |field|
        if (@db[@@table_name].columns & [:"#{field[:identity_key]}"]).blank? && (table_fields & ["#{field[:id]}".to_i]).blank?
          add_column "#{field[:identity_key]}", String
        end
      end
    end
    data_records(:create)
  end

  def update_fields
    return unless table_exists?(@@table_name)

    db_connect.alter_table @@table_name do
      @@fields.each do |field|
        unless @db[@@records].where(field_id: field[:id]).all[0][:identity_key] == field[:identity_key]
          rename_column @db[@@records].where(field_id: field[:id]).all[0][:identity_key].to_sym, "#{field[:identity_key]}".to_sym
        end
      end
    end
    data_records(:update)
  end

  def drop_fields
    return unless table_exists?(@@table_name)

    table_fields = @@fields.map { |field| field[:identity_key] }

    db_connect.alter_table @@table_name do
      @db[@@table_name].columns.each do |database_columns_field|
        next if table_fields.include?(database_columns_field.to_s) || database_columns_field == :id || database_columns_field == :created_at || database_columns_field == :updated_at
        drop_column database_columns_field
      end
    end
    data_records(:delete)
  end

  def records_create
    @@fields.each do |field|
      if db_connect[@@records].where(field_id: field[:id]).blank?
        db_connect[@@records].insert(field_id: field["id"], identity_key: "#{field["identity_key"]}")
      end
    end
  end

  def records_update
    @@fields.each do |field|
      unless db_connect[@@records].where(field_id: field[:id]).all[0][:identity_key].to_sym == field[:identity_key]
        db_connect[@@records].where(field_id: field['id']).update(identity_key: "#{field["identity_key"].to_s}")
      end
    end
  end

  def records_delete
    table_fields = @@fields.map { |field| field['id'] }

    db_connect[@@records].all.each do |database_columns_field|
      next if table_fields.include?(database_columns_field[:field_id])
      db_connect[@@records].where(field_id: database_columns_field[:field_id]).delete
    end
  end

  def data_records(status)
    create_records_table
    case status
    when :create
      records_create
    when :update
      records_update
    when :delete
      records_delete
    end
  end

  def create_records_table

    return if table_exists?(@@records)

    db_connect.create_table @@records do
      primary_key :id
      Integer :field_id
      String :identity_key
    end
  end

  def drop_table
    db_connect.drop_table(@@table_name) if table_exists?(@@table_name)

    db_connect.drop_table(@@records) if table_exists?(@@records)
  end

  def db_connect
    @db ||= Sequel.connect('sqlite://db/development.sqlite3')
  end

  def table_exists?(table_name)
    db_connect.table_exists?(table_name)
  end
end
