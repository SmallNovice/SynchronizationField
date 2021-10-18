module Sequelable
  extend ActiveSupport::Concern

  def self.create_form_table(table_name, fields = {})
    return if table_exists?(table_name)

    db_connect.create_table table_name do
      primary_key :id
      DateTime :created_at
      DateTime :updated_at
      fields.each do |k|
        String "#{k[:identity_key]}"
      end
    end
  end

  def self.create_field(table_name, fields = {}, ole_records_table_name)
    return unless table_exists?(table_name)
    
    table_fields = Sequelable.db_connect[ole_records_table_name].all.map { |field| field[:field_id] }
    Sequelable.db_connect.alter_table table_name do
      fields.each do |k|

        if (Sequelable.db_connect[table_name].columns & [:"#{k[:identity_key]}"]).blank? && (table_fields & ["#{k[:id]}".to_i]).blank?
          add_column "#{k[:identity_key]}", String
        end
      end
    end
  end

  def self.update_fields(table_name, fields = {}, ole_records_table_name)
    return unless table_exists?(table_name)

    db_connect.alter_table table_name do
      fields.each do |k|
        unless Sequelable.db_connect[ole_records_table_name].where(field_id: k[:id]).all[0][:identity_key] == k[:identity_key]
          rename_column Sequelable.db_connect[ole_records_table_name].where(field_id: k[:id]).all[0][:identity_key].to_sym, "#{k[:identity_key]}".to_sym
        end
      end
    end
  end

  def self.drop_field(table_name, fields)
    return unless table_exists?(table_name)

    table_fields = fields.map { |field| field[:identity_key] }

    db_connect.alter_table table_name do
      Sequelable.db_connect[table_name].columns.each do |k|
        next if table_fields.include?(k.to_s) || k == :id || k == :created_at || k == :updated_at
        drop_column k
      end
    end
  end

  def self.old_field_records(status, ole_records_table_name, fields = {})
    create_ole_name_records(ole_records_table_name)
    case status
    when "create"
      fields.each do |k|
        if db_connect[ole_records_table_name].where(field_id: k[:id]).blank?
          db_connect[ole_records_table_name].insert(field_id: k["id"], identity_key: "#{k["identity_key"]}")
        else
          unless db_connect[ole_records_table_name].where(field_id: k[:id]).all[0][:identity_key] == k[:identity_key]
            db_connect[ole_records_table_name].insert(field_id: k["id"], identity_key: "#{k["identity_key"]}")
          end
        end
      end
    when "update"
      fields.each do |k|
        unless db_connect[ole_records_table_name].where(field_id: k[:id]).all[0][:identity_key].to_sym == k[:identity_key]
          db_connect[ole_records_table_name].where(field_id: k['id']).update(identity_key: "#{k["identity_key"].to_s}")
        end
      end
    when "delete"
      table_fields = fields.map { |field| field['id'] }

      db_connect[ole_records_table_name].all.each do |k|
        next if table_fields.include?(k[:field_id])
        db_connect[ole_records_table_name].where(field_id: k[:field_id]).delete
      end
    end
  end

  def self.create_ole_name_records(ole_records_table_name)
    return if table_exists?(ole_records_table_name)

    db_connect.create_table ole_records_table_name do
      primary_key :id
      Integer :field_id
      String :identity_key
    end
  end

  private

  def self.db_connect
    @db ||= Sequel.connect('sqlite://db/development.sqlite3')
  end

  def self.table_exists?(table_name)
    db_connect.table_exists?(table_name)
  end
end
