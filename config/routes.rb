Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Defines the root path route ("/")
  # root "articles#index"

  post 'orders', to: 'orders#create'
  get  'orders', to: 'orders#search'
end
