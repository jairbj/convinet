class ContribuicoesController < ApplicationController
  before_action :authenticate_usuario!
  before_action :checa_telefone
  before_action :checa_endereco

  def index    
    @contribuicoes = current_usuario.contribuicoes
  end

  def new
    @contribuicao = current_usuario.contribuicoes.new
    @contribuicao.plano = Plano.find(params[:plano]);

    @session = PagSeguro::Session.create.id
  end

  def create
    @contribuicao = current_usuario.contribuicoes.new(contribuicao_params)
    @contribuicao.plano = Plano.find(params[:contribuicao][:plano]);

    unless @contribuicao.valid?
      flash[:danger] = 'Erro ao processar sua contribuição. Por favor tente novamente. COD: #03'
      redirect_to new_contribuicao_path(plano: @contribuicao.plano.id)
      return
    end

    subscription = gera_subscription(@contribuicao)

    subscription.credentials = PagSeguro::AccountCredentials.new(PagSeguro.email, PagSeguro.token)
    subscription.create

    if subscription.errors.any?
      puts 'PAGSEGURO -> ERRO CRIAR CONTRIBUIÇÃO'
      puts subscription.errors.join('\n')
      flash[:danger] = 'Erro ao processar sua contribuição. Por favor tente novamente. COD: #04'
      redirect_to new_contribuicao_path(plano: @contribuicao.plano.id)
      return
    end

    @contribuicao.codigo = subscription.code
    @contribuicao.save  
    
    flash[:success] = 'Contribuição cadastrada com sucesso.'

    redirect_to root_path

  end  

  private

  def contribuicao_params
    params.require(:contribuicao).permit(:hash_cliente,
                                         :token_cartao,
                                         :nome_cartao)
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

  def gera_subscription(contribuicao)
    if PagSeguro.environment == :sandbox
      email = 'user@sandbox.pagseguro.com.br'
    else
      email = contribuicao.usuario.email
    end
    PagSeguro::Subscription.new(
      plan: contribuicao.plano.codigo,      
      sender: {
        name: contribuicao.usuario.nome,
        email: email,
        hash: contribuicao.hash_cliente,
        phone: {
          area_code: contribuicao.usuario.telefone.ddd,
          number: contribuicao.usuario.telefone.numero
        },
        document: { 
          type: 'CPF', 
          value: contribuicao.usuario.cpf 
        },
        address: {
          street: contribuicao.usuario.endereco.rua,
          number: contribuicao.usuario.endereco.numero,
          complement: contribuicao.usuario.endereco.complemento,
          district: contribuicao.usuario.endereco.bairro,
          city: contribuicao.usuario.endereco.cidade,
          state: contribuicao.usuario.endereco.estado,
          country: 'BRA',
          postal_code: contribuicao.usuario.endereco.cep
        }
      },
      payment_method: {
        token: contribuicao.token_cartao,
        holder: {
          name: contribuicao.nome_cartao,
          birth_date: contribuicao.usuario.nascimento,
          document: { 
            type: 'CPF', 
            value: contribuicao.usuario.cpf 
          },
          billing_address: {
            street: contribuicao.usuario.endereco.rua,
            number: contribuicao.usuario.endereco.numero,
            complement: contribuicao.usuario.endereco.complemento,
            district: contribuicao.usuario.endereco.bairro,
            city: contribuicao.usuario.endereco.cidade,
            state: contribuicao.usuario.endereco.estado,
            country: 'BRA',
            postal_code: contribuicao.usuario.endereco.cep
          },
          phone: {
            area_code: contribuicao.usuario.telefone.ddd,
            number: contribuicao.usuario.telefone.numero
          }
        }
      }
    )
  end
end
