class Contribuicao < ApplicationRecord
  belongs_to :usuario
  belongs_to :plano

  enum status: { pendente: 0, ativo: 1, cancelado: 2, suspenso: 3 }

  attr_accessor :hash_cliente
  #validates_presence_of :hash_cliente
  
  attr_accessor :token_cartao
  #validates_presence_of :token_cartao

  attr_accessor :nome_cartao
  #validates_presence_of :nome_cartao 

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
end
