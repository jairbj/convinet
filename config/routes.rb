Rails.application.routes.draw do
  resources :enderecos
  resources :telefones
  devise_for :usuarios
  get 'paginas/home'

  devise_scope :usuario do
    root :to => 'devise/sessions#new'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
