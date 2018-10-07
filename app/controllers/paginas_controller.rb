class PaginasController < ApplicationController
  def home
    if usuario_signed_in?
      redirect_to :edit_usuario_registration
    else
      redirect_to :login
    end
  end
end
