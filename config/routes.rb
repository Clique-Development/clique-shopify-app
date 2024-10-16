Rails.application.routes.draw do
  root :to => 'home#index'
  get '/products', :to => 'products#index'
  get '/orders', :to => 'orders#index'
  get '/rewix_products', :to => 'products#fetch_products_from_api'
  get '/products_data_summary', :to => 'products#products_data_summary'
  get '/price_settings', :to => 'price_settings#index'
  post '/calculate_final_black_market_price', to: 'api/price_settings#calculate_final_black_market_price'
  mount ShopifyApp::Engine, at: '/'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  namespace :shopify_app do
    resources :webhooks, only: [], defaults: { format: 'json' } do
      collection do
        get :receive
      end
    end
  end
end
