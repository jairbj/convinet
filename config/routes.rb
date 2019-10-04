Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root to: 'contribuicoes#index'

  resources :planos, only: [:new, :create]

  get 'contribuicoes/new/:plano', to: 'contribuicoes#new', as: 'new_contribuicao'
  resources :contribuicoes, only: [:index, :create, :show, :destroy]
  get 'contribuicoes/atualizar_cartao/:contribuicao', to: 'contribuicoes#atualizar_cartao', as: 'atualizar_cartao'
  post 'contribuicoes/atualizar_cartao', to: 'contribuicoes#update_cartao', as: 'update_cartao'

  resources :enderecos, only: [:new, :create, :edit, :update]

  resources :telefones, only: [:new, :create, :edit, :update]

  post 'pre_cadastro', to: 'pre_cadastros#show', as: 'pre_cadastro'

  get 'paginas/home'

  devise_scope :usuario do
    get     'login',      to: 'devise/sessions#new'
    get     'cadastro',   to: 'devise/registrations#new'
    get     'logout',     to: 'usuarios/sessions#destroy'
    delete  'logout',     to: 'usuarios/sessions#destroy'
  end

  devise_for :usuarios, path_names: { sign_in: 'login',
                                      sign_out: 'logout',
                                      sign_up: 'cadastro',
                                      edit: 'meus-dados' },
                        controllers: { registrations: 'usuarios/registrations',
                                       sessions: 'usuarios/sessions' }

end
