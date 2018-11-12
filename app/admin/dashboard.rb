ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel 'Valor total mensal de contribuições ativas' do
          total = 0
          Contribuicao.ativo.each do |c|
            total += c.plano.valor.to_i
          end

          h2 "R$ #{total},00"
        end
      end
      column do
      end
    end
    columns do
      column do
        panel 'Últimas 20 contribuições (exceto canceladas)' do          
          table_for Contribuicao.where.not(status: :cancelado).order('created_at desc').last(20) do
            column("Nome")  { |c| link_to(c.usuario.nome, admin_usuario_path(c.usuario))}
            column("Valor") { |c| link_to("R$ #{c.plano.valor.to_i},00", admin_contribuicao_path(c.id))}
            column("Status") { |c| c.status.to_s.capitalize}
            column("Data de Início") { |c| c.created_at.to_date}
          end
        end
      end
      column do
        panel 'Últimas 20 contribuições canceladas' do
          table_for Contribuicao.cancelado.order('created_at desc').last(20) do
            column("Nome")  { |c| link_to(c.usuario.nome, admin_usuario_path(c.usuario))}
            column("Valor") { |c| "R$ #{c.plano.valor.to_i},00"}
            column("Data de Início") { |c| c.created_at.to_date}
          end
        end
      end
    end
        

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end
