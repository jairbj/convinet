class Usuario < ApplicationRecord
  has_one :endereco
  has_one :telefone
  has_many :contribuicoes
  has_many :pre_cadastros

  def to_s
    "#{nome} - #{email}"
  end

  accepts_nested_attributes_for :telefone
  accepts_nested_attributes_for :endereco

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Validações
  # Nome
  validates_presence_of :nome
  # Nascimento
  validates_presence_of :nascimento
  validates_length_of :nascimento, is: 10
  validates :nascimento, format: {with: /\A[0-9]{2}\/[0-9]{2}\/[0-9]{4}\z/, message: "formato inválido. Deve ser DD/MM/AAAA"}

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

  def cpf_formatado
    CPF.new(self.cpf).formatted
  end
end
