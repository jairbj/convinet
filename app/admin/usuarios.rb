ActiveAdmin.register Usuario do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
  actions :all, except: [:destroy]

  member_action :logar, method: :put do
    sign_in(:usuario, resource)
    redirect_to root_path
  end

  member_action :resetar_senha, method: :put do
    resource.password = resource.cpf
    resource.password_confirmation = resource.password

    if resource.save
      redirect_to admin_usuario_path(resource),
                  notice: 'Senha resetada com sucesso. A nova senha é o CPF do usuário, sem pontos e sem traços.'
    else
      redirect_to admin_usuario_path(resource),
                  alert: 'Erro ao resetar senha do usuário, tente novamente.'
    end
  end

  action_item :pre_cadastro, only: :show do
    link_to 'Criar pré-cadastro', new_admin_pre_cadastro_path(pre_cadastro: { usuario_id: resource.id })
  end

  action_item :logar, only: :show do
    link_to 'Logar como usuário',
            logar_admin_usuario_path(resource),
            method: :put
  end

  action_item :resetar_senha, only: :show do
    link_to 'Resetar senha',
            resetar_senha_admin_usuario_path(resource),
            method: :put,
            data: { confirm: "Tem certeza que deseja resetar a senha do usuário #{usuario.nome}? Essa operação não poderá ser desfeita" }
  end

  permit_params :nome,
                :email,
                :cpf,
                :nascimento,
                telefone_attributes: [:id,
                                      :ddd,
                                      :numero],
                endereco_attributes: [:id,
                                      :rua,
                                      :numero,
                                      :complemento,
                                      :bairro,
                                      :cidade,
                                      :estado,
                                      :cep]

  filter :nome
  filter :cpf

  index do
    selectable_column
    id_column
    column(:nome) { |c| link_to(c.nome, admin_usuario_path(c)) }
    column :email
    column 'CPF', :cpf_formatado
    actions
  end

  show do
    attributes_table do
      row :id
      row :nome
      row :email
      row 'CPF' do
        usuario.cpf_formatado
      end
      row 'Data de Nascimento' do
        usuario.nascimento
      end
      row 'Data de Cadastro' do
        usuario.created_at
      end
    end

    panel 'Telefone' do
      attributes_table_for usuario.telefone do
        row :ddd
        row :numero
      end
    end

    panel 'Endereco' do
      attributes_table_for usuario.endereco do
        row :rua
        row :numero
        row :complemento
        row :bairro
        row :cidade
        row :estado
        row :cep
      end
    end

    panel 'Contribuicões' do
      table_for usuario.contribuicoes do
        column 'Valor mensal' do |c|
          link_to("R$ #{c.plano.valor.to_i},00", admin_contribuicao_path(c.id))
        end
        column('Status') {|c| c.status.capitalize}
        column('Data de Início') {|c| c.created_at}
        column('ID no PagSeguro') {|c| c.codigo}
      end
    end
    active_admin_comments
  end

  before_create do |u|
    u.password = u.cpf
    u.password_confirmation = u.cpf
  end

  form do |f|
    f.semantic_errors
    f.inputs 'Usuário' do
      input :nome
      input :email      
      input :cpf, label: "CPF (somente números):"
      input :nascimento, label: 'Data de Nascimento',
                         start_year: Date.today.year - 100,
                         end_year: Date.today.year

      if f.object.new_record?

        li do
          strong 'ATENÇÃO: A senha do usuário será o número do CPF, sem pontos e sem hífen.'.html_safe
        end

        unless f.object.telefone
          f.object.telefone = Telefone.new
        end
        unless f.object.endereco
          f.object.endereco = Endereco.new
        end
      end

      f.has_many :telefone, allow_destroy: false, new_record: false do |t|
        t.input :ddd
        t.input :numero
      end

      f.has_many :endereco, allow_destroy: false, new_record: false do |e|
        e.input :rua
        e.input :numero
        e.input :complemento
        e.input :bairro
        e.input :cidade
        e.input :estado
        e.input :cep
      end
    end
    f.actions
  end
end
