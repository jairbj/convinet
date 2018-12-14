class ContribuicoesController < ApplicationController
  before_action :authenticate_usuario!
  before_action :checa_telefone
  before_action :checa_endereco

  def index    
    @contribuicoes = current_usuario.contribuicoes.order 'id desc'
  end

  def new
    @contribuicao = current_usuario.contribuicoes.new
    @contribuicao.plano = Plano.find(params[:plano]);

    @session = PagSeguro::Session.create.id
  end

  def show
    @contribuicao = current_usuario.contribuicoes.find(params[:id])
    
    # Atualiza o status da contribuição
    credentials = PagSeguro::AccountCredentials.new(PagSeguro.email, PagSeguro.token)
    @subscription = PagSeguro::Subscription.find_by_code(@contribuicao.codigo, credentials: credentials)

    unless @subscription
      flash[:danger] = 'Erro ao conectar ao PagSeguro. Por favor tente novamente. COD: #05'
      puts 'PAGSEGURO -> ERRO BUSCAR CONTRIBUIÇÃO'
      puts subscription.to_yaml
      redirect_to contribuicoes_path
      return
    end

    if @subscription.errors.any?
      flash[:danger] = 'Erro ao conectar ao PagSeguro. Por favor tente novamente. COD: #06'
      puts 'PAGSEGURO -> ERRO BUSCAR CONTRIBUIÇÃO'
      puts @subscription.errors.join('\n')
      redirect_to contribuicoes_path
      return
    end

    @contribuicao.atualizar_status(@subscription.status)    
    @contribuicao.save
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
    begin
      subscription.create      
    rescue
      if recupera_contribuicao(@contribuicao.usuario, true)
        flash[:info] = 'Houve um erro na comunicação com o PagSeguro. 
                        Verifique abaixo se sua contribuição foi cadastrada.
                        Antes de tentar novamente, 
                        verifique a fatura do seu cartão de crédito 
                        e se já foi debitado, entre em contato com algum 
                        responsável pelo projeto.'
      else
        flash[:danger] = 'Erro ao processar sua contribuição. 
                          Antes de tentar novamente, 
                          verifique a fatura do seu cartão de crédito 
                          e se já foi debitado, entre em contato com algum 
                          responsável pelo projeto.'
      end
      redirect_to root_path
      return
    end

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

  def destroy
    @contribuicao = current_usuario.contribuicoes.find(params[:id])
    
    cancel = PagSeguro::SubscriptionCanceller.new(subscription_code: @contribuicao.codigo)

    cancel.credentials = PagSeguro::AccountCredentials.new(PagSeguro.email, PagSeguro.token)
    
    begin
      cancel.save
    rescue
      flash[:error] = 'Houve um erro ao efetuar o cancelamento da sua contribuição. Por favor tente novamente'
      redirect_to @contribuicao
      return
    end

    if cancel.errors.any?
      flash[:danger] = 'Houve um erro ao efetuar o cancelamento da sua contribuição. Por favor tente novamente'
      puts 'PAGSEGURO -> ERRO CANCELAR CONTRIBUIÇÃO'
      puts cancel.errors.join('\n')
    else
      flash[:success] = 'Contribuição cancelada com sucesso.'      
    end

    redirect_to @contribuicao
  end

  def atualizar_cartao
    @contribuicao = current_usuario.contribuicoes.find params[:contribuicao]
    @session = PagSeguro::Session.create.id
  end

  def update_cartao
    @contribuicao = current_usuario.contribuicoes.find(params[:contribuicao][:contribuicao])    
    @contribuicao.hash_cliente = params[:contribuicao][:hash_cliente]
    @contribuicao.token_cartao = params[:contribuicao][:token_cartao]
    @contribuicao.nome_cartao = params[:contribuicao][:nome_cartao]

    changePayment = gera_subscription_change_payment(@contribuicao)
    changePayment.credentials = PagSeguro::AccountCredentials.new(PagSeguro.email, PagSeguro.token)
    begin
      changePayment.update
    rescue
      flash[:danger] = 'Erro ao processar atualização do cartão de crédito junto ao PagSeguro, por favor tente novamente.'
      redirect_to atualizar_cartao_path(contribuicao: @contribuicao.id)
      return
    end
    
    if changePayment.errors.any? 
      flash[:error] = 'Erro ao atualizar cartão de crédito junto ao PagSeguro, por favor tente novamente.'
      redirect_to atualizar_cartao_path(contribuicao: @contribuicao.id)
      puts 'PAGSEGURO -> ERRO ATUALIZAR CARTÃO'
      puts changePayment.errors.join('\n')
    else
      flash[:success] = 'Cartão de crédito atualizado com sucesso.'
      redirect_to @contribuicao      
    end
  end

  private

  def contribuicao_params
    params.require(:contribuicao).permit(:hash_cliente,
                                         :token_cartao,
                                         :nome_cartao)
  end

  def checa_telefone
    unless current_usuario.telefone
      flash[:info] = 'Antes de contribuir é necessário cadastrar seu telefone.'
      redirect_to :new_telefone      
    end
  end

  def checa_endereco
    unless current_usuario.endereco
      flash[:info] = 'Antes de contribuir é necessário cadastrar seu endereço.'
      redirect_to :new_endereco      
    end
  end


  def recupera_contribuicao(usuario, aguarda = false)
    sleep 5 if aguarda

    credentials = PagSeguro::AccountCredentials.new(PagSeguro.email, PagSeguro.token)

    if PagSeguro.environment == :sandbox
      email = "user#{usuario.id}@sandbox.pagseguro.com.br"
    else
      email = usuario.email
    end
    
    options = {
      credentials: credentials,      
      starts_at: Time.now.in_time_zone('Brasilia') - 15.minutes,
      ends_at: Time.now.in_time_zone('Brasilia'),
      sender_email: email
    }

    begin
      report = PagSeguro::Subscription.search_by_date_interval(options)
    rescue
      return false
    end

    unless report.valid?
      puts "PAGSEGURO: Erro recuperar contribuicao"
      puts report.errors.join("\n")
      puts options
      return false
    end
      
    contribuicoes_recuperadas = 0
      
    while report.next_page?      
      report.next_page!
      report.subscriptions.each do |s|
        unless usuario.contribuicoes.find_by codigo: s.code          
          plano = Plano.find_by nome: s.name
          if plano
            c = usuario.contribuicoes.new
            c.codigo = s.code
            c.atualizar_status(s.status)
            c.plano = plano
            contribuicoes_recuperadas += 1 if c.save
          end
        end
      end    
    end

    return false unless contribuicoes_recuperadas
    contribuicoes_recuperadas              
  end

  def gera_subscription_change_payment(contribuicao)
    if PagSeguro.environment == :sandbox
      email = "user#{contribuicao.usuario.id}@sandbox.pagseguro.com.br"
    else
      email = contribuicao.usuario.email
    end

    PagSeguro::SubscriptionChangePayment.new(
      subscription_code: contribuicao.codigo,
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
      subscription_payment_method: {
        token: contribuicao.token_cartao,
        holder: {
          name: contribuicao.nome_cartao,
          birth_date: contribuicao.usuario.nascimento,
          phone: {
            area_code: contribuicao.usuario.telefone.ddd,
            number: contribuicao.usuario.telefone.numero
          },
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
        }
      }
    )
  end

  def gera_subscription(contribuicao)
    if PagSeguro.environment == :sandbox
      email = "user#{contribuicao.usuario.id}@sandbox.pagseguro.com.br"
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
