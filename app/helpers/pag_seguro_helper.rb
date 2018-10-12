module PagSeguroHelper
  def status_pagamento_texto(status)
    case status
    when :processing
      return 'Em processamento'
    when :scheduled
      return 'Agendado'
    when :paid
      return 'Pago'
    when :not_paid
      return 'Não pago'
    else
      return status
    end
  end
end