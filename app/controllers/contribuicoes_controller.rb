class ContribuicoesController < ApplicationController
  before_action :authenticate_usuario!
  before_action :checa_telefone
  before_action :checa_endereco

  def index    
    @contribuicoes = current_usuario.contribuicoes
  end

  def new
    @contribuicao = current_usuario.contribuicoes.new
  end

  def create
    @contribuicao = current_usuario.contribuicoes.new
  end  

  private

  def telefone_params
    params.require(:contribuicao).permit(:valor,
                                          :numero)
  end

  def checa_telefone
    unless current_usuario.telefone
      flash[:info] = 'Antes de poder fazer contribuições é necessário cadastrar seu telefone.'
      redirect_to :new_telefone      
    end
  end

  def checa_endereco
    unless current_usuario.endereco
      flash[:info] = 'Antes de poder fazer contribuições é necessário cadastrar seu endereço.'
      redirect_to :new_endereco      
    end
  end
end
