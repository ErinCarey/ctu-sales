Rails.application.routes.draw do
  resources :sales
  resources :products
  devise_for :users

  get '/buy/:permalink', to: 'transactions#new', as: :show_buy
  post '/buy/:permalink', to: 'transactions#create', as: :buy
  get '/pickup/:guid', to: 'transactions#pickup', as: :pickup
  get '/stock-up-and-save/:guid', to: 'transactions#upsell', as: :upsell
  get '/download/:guid', to: 'transactions#download', as: :download
  match '/iframe/:permalink' => 'transactions#iframe', via: :get, as: :buy_iframe
  match '/status/:guid'      => 'transactions#status',   via: :get,  as: :status
  mount StripeEvent::Engine => '/stripe-events'

end
