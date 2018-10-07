Rails.application.routes.draw do
  resources :enderecos, except: [:destroy, :index]
  resources :telefones, except: [:destroy, :index]
  
  get 'paginas/home'

  root :to => 'paginas#home'

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
