class Endereco < ApplicationRecord
  belongs_to :usuario
  before_validation :upper_estado

  # Validações
  # rua
  validates_presence_of :rua
  validates_length_of :rua, maximum: 80
  # numero
  validates_presence_of :numero
  validates_length_of :numero, maximum: 20
  # complemento
  validates_presence_of :complemento
  validates_length_of :complemento, maximum: 40
  # bairro
  validates_presence_of :bairro
  validates_length_of :bairro, maximum: 60
  # cidade
  validates_presence_of :cidade
  validates_length_of :cidade, minimum: 2, maximum: 60
  # estado
  validates_presence_of :estado
  validates_length_of :estado, is: 2
  validates :estado, inclusion: {in: %w(AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO), 
                                 message: 'não é uma sigla válida'}
  # cep
  validates_presence_of :cep
  validates_length_of :cep, is: 8
  validates_numericality_of :cep

  def upper_estado
    estado.upcase!
  end
end
