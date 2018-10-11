class Contribuicao < ApplicationRecord
  belongs_to :usuario
  belongs_to :plano

  enum status: { processando: 0, ativo: 1, cancelado: 2 }

  attr_accessor :hash_cliente
  validates_presence_of :hash_cliente
  
  attr_accessor :token_cartao
  validates_presence_of :token_cartao

  attr_accessor :nome_cartao
  validates_presence_of :nome_cartao 
end
