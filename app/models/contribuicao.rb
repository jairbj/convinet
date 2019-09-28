class Contribuicao < ApplicationRecord
  belongs_to :usuario
  belongs_to :plano

  enum status: { pendente: 0, ativo: 1, cancelado: 2, suspenso: 3 }
  enum tipo: { mensal: 0, avulsa: 1 }

  attr_accessor :hash_cliente
  attr_accessor :token_cartao
  attr_accessor :nome_cartao

  def check_status
    # Atualiza o status da contribuição pelo status do pagseguro
    credentials = PagSeguro::AccountCredentials.new(PagSeguro.email, PagSeguro.token)
    subscription = PagSeguro::Subscription.find_by_code(self.codigo, credentials: credentials)

    unless subscription
      puts 'PAGSEGURO -> ERRO BUSCAR CONTRIBUIÇÃO'
      puts subscription.to_yaml
      return false
    end

    if subscription.errors.any?
      puts 'PAGSEGURO -> ERRO BUSCAR CONTRIBUIÇÃO'
      puts subscription.errors.join('\n')
      return false
    end

    self.atualizar_status(subscription.status)
    self.save
  end

  def atualizar_status(novo_status)
    self.status = case novo_status.upcase
                  when 'PENDING'
                    :pendente
                  when 'ACTIVE'
                    :ativo
                  when 'CANCELLED'
                    :cancelado
                  when 'CANCELLED_BY_SENDER'
                    :cancelado
                  when 'CANCELLED_BY_RECEIVER'
                    :cancelado
                  when 'SUSPENDED'
                    :suspenso
                  end
  end

  def pagamentos
    c = self
    options = { credentials: PagSeguro::AccountCredentials.new(PagSeguro.email, PagSeguro.token)}
    report = PagSeguro::SubscriptionSearchPaymentOrders.new(c.codigo, '', options)

    unless report.valid?
      puts "PAGSEGURO: Erro recuperar contribuicao"
      puts report.errors.join("\n")
      puts options
      return nil
    end

    pagamentos = Array.new
    while report.next_page?
      report.next_page!

      report.payment_orders.each do |p|
        pagamentos << p
      end
    end
    pagamentos.sort_by! &:last_event_date
    return pagamentos
  end

  def payment_cancel
    c = self

    cancel = PagSeguro::SubscriptionCanceller.new(subscription_code: c.codigo)
    cancel.credentials = PagSeguro::AccountCredentials.new(PagSeguro.email, PagSeguro.token)

    begin
      cancel.save
    rescue
      puts 'PAGSEGURO -> ERRO CANCELAR CONTRIBUIÇÃO - CANCEL.SAVE'
      return false
    end

    if cancel.errors.any?
      puts 'PAGSEGURO -> ERRO CANCELAR CONTRIBUIÇÃO'
      puts cancel.errors.join('\n')
      return false
    else
      return true
    end
  end

  def payment_retry 
    c = self

    p = pagamentos
    return false unless p

    p_retry = PagSeguro::SubscriptionRetry.new(
      subscription_code: c.codigo,
      payment_order_code: p.last.code
    )

    p_retry.credentials = PagSeguro::AccountCredentials.new(PagSeguro.email, PagSeguro.token)
    p_retry.save

    if p_retry.errors.any?
      puts 'PAGSEGURO -> ERRO RETENTATIVA DE PAGAMENTO'
      puts p_retry.errors.join('\n')
      return false
    else
      return true
    end
  end
end
