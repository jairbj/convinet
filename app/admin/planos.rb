ActiveAdmin.register Plano do
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
  actions :index, :show

  config.sort_order = 'valor_asc'

  filter :valor

  index do    
    column 'Nome' do |c|
      link_to c.nome, admin_plano_path(c.id)
    end
    column 'Valor mensal' do |c|
      "R$ #{c.valor.to_i},00"
    end
    column 'Contribuições Ativas' do |c|
      c.contribuicoes.ativo.count
    end
  end

  show do
    attributes_table do
      row :nome
      row 'Valor Mensal' do
        "R$ #{plano.valor.to_i},00"
      end
      row 'Código PagSeguro' do
        plano.codigo        
      end
      row 'Link de Pagamento' do
        link = "https://pagseguro.uol.com.br/pre-approvals/request.html?code=#{plano.codigo}"
        link_to link, link
      end

    end
  end

end
