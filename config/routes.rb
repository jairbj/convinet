Rails.application.routes.draw do
  resources :enderecos
  resources :telefones
  
  get 'paginas/home'

  devise_scope :usuario do
    root :to => 'devise/sessions#new'
    get     'login',      to: 'devise/sessions#new'
    get     'cadastro',   to: 'devise/registrations#new'
    get     'logout',     to: 'devise/sessions#destroy'
    delete  'logout',     to: 'devise/sessions#destroy'
  end

  devise_for :usuarios, path_names: { sign_in: 'login',
                                      sign_out: 'logout',
                                      sign_up: 'cadastro',
                                      edit: 'perfil' },
                        controllers: { registrations: 'usuarios/registrations'}
  
end
