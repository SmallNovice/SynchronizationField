class TableMapper
  class TableMapperDeleter < TableMapper

    def run(sequelable)
      
      sequelable.drop_table
      
    end
  end
end

