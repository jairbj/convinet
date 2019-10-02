class PreCadastrosController < ApplicationController
  def show
    @pre_cadastro = PreCadastro.ativo.find_by(codigo: pre_cadastro_params['codigo'])

    return if @pre_cadastro

    flash[:error] = 'Código de Pré-Cadastro inválido. Tente novamente.'
    redirect_to new_usuario_session_path
  end

  private

  def pre_cadastro_params
    params.require(:pre_cadastro).permit(:codigo)
  end
end
