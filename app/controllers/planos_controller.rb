class PlanosController < ApplicationController
  def new
    @plano = Plano.new
  end

  def create
    @plano = Plano.new(plano_params)
    if @plano.valor.integer?
      plano = Plano.find_by(valor: @plano.valor)
      if plano
        redirect_to new_contribuicao_path(plano: plano.id)
        return
      end

      @plano.identificador = Rails.configuration.convinet['prefixo_plano_pagseguro'] + @plano.valor.to_i.to_s
      @plano.nome = @plano.identificador

      @plano.codigo = cria_plano_pagseguro(@plano)

      if @plano.codigo
        @plano.save
        redirect_to new_contribuicao_path(plano: @plano.id)
      else
        flash[:danger] = 'Erro ao comunicar com o PagSeguro, por favor tente novamente'
        render :new
      end
    else
      flash[:danger] = 'Valor inválido. Informe um valor inteiro sem casas decimais'
      render :new
    end    
  end

  private

  def plano_params
    params.require(:plano).permit(:valor)
  end

  def cria_plano_pagseguro(plano)
    p = PagSeguro::SubscriptionPlan.new(
      charge: 'auto', 
      reference: plano.identificador,
      name: plano.nome,   
      period: 'Monthly',      
      amount: plano.valor.to_i,
      redirect_url: Rails.configuration.convinet['pagseguro_redirect'],
      review_url: Rails.configuration.convinet['pagseguro_redirect']
    )

    p.credentials = PagSeguro::AccountCredentials.new(PagSeguro.email, PagSeguro.token)
    p.create

    if p.errors.any?
      puts 'ERRO PAGSEGURO =>'
      puts p.errors.join("\n")
      nil
    else
      p.code
    end
  end
end
