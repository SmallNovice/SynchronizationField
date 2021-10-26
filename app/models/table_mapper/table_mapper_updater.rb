class TableMapper
  class TableMapperUpdater < TableMapper
    
    def run(sequelable)
      #创建表
      sequelable.create_form_table
      
      #创建字段
      sequelable.create_fields

      #更新字段
      sequelable.update_fields

      #删除字段
      sequelable.drop_fields
    end
  end
end
