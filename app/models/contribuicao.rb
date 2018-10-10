class Contribuicao < ApplicationRecord
  belongs_to :usuario
  belongs_to :plano

  enum status: { processando: 0, ativo: 1, cancelado: 2 }

  attr_accessor :valor
end
