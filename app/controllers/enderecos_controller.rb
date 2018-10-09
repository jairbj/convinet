class EnderecosController < ApplicationController
  before_action :authenticate_usuario!
  before_action :unico_endereco, only: [:new, :create]

  # GET /enderecos/new
  def new    
    @endereco = Endereco.new
  end

  # POST /enderecos
  def create
    @endereco = Endereco.new(endereco_params)
    @endereco.usuario = current_usuario

    if @endereco.save
      flash[:success] = 'Endereço cadastrado com sucesso'
      redirect_to root_url
    else
      flash_errors(@endereco)
      render :new
    end
  end

  private

  def endereco_params
    params.require(:endereco).permit(:rua,
                                     :numero,
                                     :complemento,
                                     :bairro,
                                     :cidade,
                                     :estado,
                                     :cep)
  end

  def unico_endereco
    redirect_to root_url if current_usuario.endereco
  end
end
