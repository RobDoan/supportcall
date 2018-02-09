Rails.application.routes.draw do

  match '/welcome_ivr', to: 'twilio#welcome_ivr', via: [:get, :post]
  match '/ivr_response', to: 'twilio#ivr_response', via: [:get, :post]
  match '/ivr_response/:api_ai_session_id', to: 'twilio#ivr_response', via: [:get, :post]
  root 'twilio#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
