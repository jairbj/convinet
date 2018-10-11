Rails.application.routes.draw do
  root :to => 'contribuicoes#index'

  resources :planos, only: [:new, :create]

  get 'contribuicoes/new/:plano', to: 'contribuicoes#new', as: 'new_contribuicao'
  get 'contribuicoes/verifica'
  resources :contribuicoes, only: [:index, :create, :show]

  resources :enderecos, only: [:new, :create, :edit, :update]

  resources :telefones, only: [:new, :create, :edit, :update]
  
  get 'paginas/home'

  devise_scope :usuario do    
    get     'login',      to: 'devise/sessions#new'
    get     'cadastro',   to: 'devise/registrations#new'
    get     'logout',     to: 'devise/sessions#destroy'
    delete  'logout',     to: 'devise/sessions#destroy'
  end

  devise_for :usuarios, path_names: { sign_in: 'login',
                                      sign_out: 'logout',
                                      sign_up: 'cadastro',
                                      edit: 'meus-dados' },
                        controllers: { registrations: 'usuarios/registrations'}
  
end
