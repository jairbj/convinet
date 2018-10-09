class TelefonesController < ApplicationController
  before_action :authenticate_usuario!
  before_action :unico_telefone, only: [:new, :create]

  # GET /telefones/new
  def new    
    @telefone = Telefone.new
  end

  # POST /telefones
  def create
    @telefone = Telefone.new(telefone_params)
    @telefone.usuario = current_usuario

    if @telefone.save
      flash[:success] = 'Telefone cadastrado com sucesso'
      redirect_to root_url
    else
      flash_errors(@telefone)
      render :new
    end

  end

  private 

  # Never trust parameters from the scary internet,
  # only allow the white list through.
  def telefone_params
    params.require(:telefone).permit(:ddd,
                                   :numero)
  end

  def unico_telefone
    redirect_to root_url if current_usuario.telefone
  end
end
