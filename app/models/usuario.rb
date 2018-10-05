class Usuario < ApplicationRecord
  has_one :endereco
  has_one :telefone
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Validações
  # Nome
  validates_presence_of :nome
  # Email
  validates_presence_of :email 
  validates :email, email_format: true
  validates_uniqueness_of :email
  # CPF
  validates_presence_of :cpf
  validates_length_of :cpf, is: 11
  validates_numericality_of :cpf
  validates :cpf, cpf_valido: true
  validates_uniqueness_of :cpf
end
