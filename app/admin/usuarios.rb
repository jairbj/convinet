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
  actions :all, except: [:new, :destroy]

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
    column :nome
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
    active_admin_comments
  end

  form do |f|
    f.semantic_errors
    f.inputs 'Usuário' do
      input :nome
      input :email
      input :cpf 
      input :nascimento, label: 'Data de Nascimento'     

      f.has_many :telefone, allow_destroy: false, new_record: false do |t|
        t.input :ddd
        t.input :numero
      end

      f.has_many :endereco, allow_destroy: false, new_record: false do |t|
        t.input :rua
        t.input :numero
        t.input :complemento
        t.input :bairro
        t.input :cidade
        t.input :estado
        t.input :cep       
      end
    end
    f.actions
  end

end
