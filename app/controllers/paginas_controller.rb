class PaginasController < ApplicationController
  def home
    if usuario_signed_in?
      unless current_usuario.telefone
        flash[:info] = 'Antes de poder fazer contribuições é necessário cadastrar seu telefone.'
        redirect_to :new_telefone
        return
      end
      unless current_usuario.endereco
        flash[:info] = 'Antes de poder fazer contribuições é necessário cadastrar seu endereço.'
        redirect_to :new_endereco
        return
      end

    else
      redirect_to :login
    end
  end
end
