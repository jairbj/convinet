class Plano < ApplicationRecord
  has_many :contribuicoes

  # Valor
  validates_numericality_of :valor  
end
