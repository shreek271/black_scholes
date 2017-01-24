Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :products do
  	get :simulation_result
  end
  root to: "static_pages#home"
end
