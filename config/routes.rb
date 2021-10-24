Rails.application.routes.draw do
  post  '/receive',  to: 'table_mappers#receive'
end
