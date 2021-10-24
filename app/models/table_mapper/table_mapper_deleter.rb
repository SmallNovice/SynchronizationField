class TableMapper
  class TableMapperDeleter < TableMapper

    include FormTableName

    def run(table_name, fields = {}, records)
      sequelable = Sequelable.new(table_name, fields, records)
      
      sequelable.drop_table
      
    end
    
    def delete
      TableMapper.find
    end
  end
end

