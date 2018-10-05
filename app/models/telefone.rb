class Telefone < ApplicationRecord
  belongs_to :usuario

  #Validacoes
  #ddd
  validates_presence_of :ddd
  validates_length_of :ddd, is: 2
  validates_numericality_of :ddd
  #numero
  validates_presence_of :numero
  validates_length_of :numero, minimum: 8, maximum: 9
  validates_numericality_of :numero
end
