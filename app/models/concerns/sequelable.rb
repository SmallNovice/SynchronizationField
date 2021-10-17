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
  
  def self.create_field(table_name, fields = {})
    return unless table_exists?(table_name)

    db_connect.alter_table table_name do
      fields.each do |k|
        if (Sequelable.db_connect[table_name].columns & [:"#{k[:identity_key]}"]).blank?
          add_column "#{k[:identity_key]}", String
        end
      end
    end
  end

  def self.update_fields(table_name, fields = {}, ole_records_table_name)
    return unless table_exists?(table_name)

    db_connect.alter_table table_name do
      fields.each do |k|
        rename_column Sequelable.db_connect[ole_records_table_name].where(field_id: k[:id]).all[0][:identity_key].to_sym, "#{k[:identity_key]}"
      end
    end
  end

  def self.drop_field(table_name, field)
    return unless @db[:"#{table_name}"].columns.include?(:"#{field}")

    db_connect.drop_column :"#{table_name}", :"#{field}"
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
      # fields.each do |k|
      #   unless db_connect[ole_records_table_name].where(:field_id).all
      #     posts.where(db_connect[ole_records_table_name][:field_id] = k['id']).delete
      #   end
      # end
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
    return @db if @db
    @db = Sequel.connect('sqlite://db/development.sqlite3')
  end

  def self.table_exists?(table_name)
    db_connect.table_exists?(table_name)
  end
end
