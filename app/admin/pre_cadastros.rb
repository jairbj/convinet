ActiveAdmin.register PreCadastro do
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
  actions :all, except: [:destroy, :edit]

  permit_params :usuario_id,
                :tipo,
                :valor

  filter :status, as: :select, collection: PreCadastro.status
  filter :codigo
  filter :usuario
  filter :valor

  member_action :cancelar, method: :put do
    return unless resource.ativo?

    # TODO: Corrigir essa lógica do valor no model
    resource.valor = resource.valor.to_i
    resource.cancelado!
    redirect_to resource_path, notice: 'Pré-Cadastro cancelado.'
  end

  action_item :cancelar,
              only: :show,
              if: proc { resource.ativo? } do
    link_to 'Cancelar Pré-Cadastro',
            cancelar_admin_pre_cadastro_path(resource),
            method: :put
  end

  index do
    selectable_column
    id_column
    column(:codigo) { |p| link_to(p.codigo, admin_pre_cadastro_path(p)) }
    column :usuario
    column :status
    column :tipo
    column :valor
    column('Data do Pré-Cadastro') { |p| p.created_at }
    actions
  end

  show do
    attributes_table do
      row('Código') { |p| strong p.codigo}
      row :usuario
      row :status
      row :tipo
      row('Valor') { |p| "R$ #{p.valor.to_i},00" }
      row('Data do Pré-Cadastro') { |p| p.created_at }
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs 'Pré Cadastro' do
      input :usuario
      # input :tipo
      input :valor
      li do
        'Informe o valor sem casas decimais'
      end
    end
    f.actions
  end
end
