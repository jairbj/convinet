class Plano < ApplicationRecord
  has_many :contribuicoes

  # Valor
  validates_numericality_of :valor
  validates_presence_of :valor  
end
