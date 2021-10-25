class TableMapper < ApplicationRecord
  include FormTableName
  serialize :fields, Array
  
  
end
