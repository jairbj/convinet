ActiveAdmin.register Contribuicao do
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
  
    filter  :usuario, collection: -> {Usuario.all.map { |u| [u.nome, u.id]}}
    filter  :status, as: :select, collection: Contribuicao.status
    filter  :plano, label: 'Valor mensal', as: :select,
            collection: -> { Plano.all.order('valor asc').map { |p|  ["R$ #{p.valor.to_i},00", p.id]}}


    member_action :payment_cancel, method: :post do
      if resource.payment_cancel
        flash[:notice] = 'Contribuição cancelada com sucesso.'
      else
        flash[:error] = 'Erro ao solicitar cancelamento de contribuição. Tente novamente.'
      end
      resource.check_status
      redirect_to admin_contribuicao_path(id: resource.id)
    end

    member_action :payment_retry, method: :post do
      if resource.payment_retry
        flash[:notice] = 'Retentativa de pagamento SOLICITADA com sucesso.'
      else
        flash[:error] = 'Erro ao solicitar retentativa de pagamento. Tente novamente.'
      end
      redirect_to admin_contribuicao_path(id: resource.id)
    end
  
    action_item :payment_cancel, only: :show do
      unless resource.cancelado?
        link_to 'Cancelar Contribuição',
                payment_cancel_admin_contribuicao_path,
                method: :post,
                data: {confirm: 'Tem certeza que deseja cancelar essa contribuição? Essa operação não poderá ser desfeita.'}
      end
    end
  
    action_item :payment_retry, only: :show do
      unless resource.cancelado?
        if resource.pagamentos.last.status == :not_paid
          link_to 'Retentativa de Pagamento',
                  payment_retry_admin_contribuicao_path,
                  method: :post
        end
      end
    end
  
    index do
      selectable_column
      id_column
      column('Usuário') { |c| c.usuario.nome }
      column('Valor mensal') { |c| "R$ #{c.plano.valor.to_i},00"}
      column('Status') { |c| c.status.to_s.capitalize}
      column('Data de Início') { |c| c.created_at.to_date}
      actions
    end

    show do
      resource.check_status

      attributes_table do
        row :id
        row('Usuario') { |c| link_to("#{c.usuario.nome} - #{c.usuario.email}", admin_usuario_path(c.usuario))}
        row('Valor mensal') { |c| "R$ #{c.plano.valor.to_i},00"}
        row('Status') { contribuicao.status.to_s.capitalize}
        row('Data de Início') { contribuicao.created_at.to_date}
        row :codigo
      end

      panel 'Pagamentos' do
        pagamentos = contribuicao.pagamentos

        table_for pagamentos do
          column('Data do Pagamento') { |p| p.scheduling_date.to_date}
          column('Status') { |p| status_pagamento_texto(p.status)}
          column('Código do Pagamento no PagSeguro') {|p| p.code}
        end
      end
    end
  end  