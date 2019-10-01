class PlanosController < ApplicationController
  before_action :authenticate_usuario!
  
  def new
    @plano = Plano.new
  end

  def create
    @plano = Plano.new(plano_params)
    if @plano.valid?
      plano = Plano.find_by(valor: @plano.valor)
      if plano
        redirect_to new_contribuicao_path(plano: plano.id)
        return
      end

      @plano.identificador = Rails.configuration.convinet['prefixo_plano_pagseguro'] + @plano.valor.to_i.to_s
      @plano.nome = @plano.identificador

      @plano.codigo = @plano.criaPagSeguro

      if @plano.codigo
        @plano.save
        redirect_to new_contribuicao_path(plano: @plano.id)
      else
        flash[:danger] = 'Erro ao comunicar com o PagSeguro, por favor tente novamente'
        render :new
      end
    else
      flash_errors(@plano)
      render :new
    end
  end

  private

  def plano_params
    params.require(:plano).permit(:valor)
  end
end
