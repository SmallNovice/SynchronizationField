Rails.application.routes.draw do
  post  '/receive',  to: 'initial_field_to_form_fields#receive'
end
