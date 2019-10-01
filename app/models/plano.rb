class Plano < ApplicationRecord
  has_many :contribuicoes

  def to_s
    nome
  end

  # Valor
  validates_numericality_of :valor
  validates_presence_of :valor

  def criaPagSeguro
    p = PagSeguro::SubscriptionPlan.new(
      charge: 'auto',
      reference: identificador,
      name: nome,
      period: 'Monthly',
      amount: valor.to_i,
      redirect_url: Rails.configuration.convinet['pagseguro_redirect'],
      review_url: Rails.configuration.convinet['pagseguro_redirect']
    )

    p.credentials = PagSeguro::AccountCredentials.new(PagSeguro.email, PagSeguro.token)
    p.create

    if p.errors.any?
      puts 'ERRO PAGSEGURO =>'
      puts p.errors.join("\n")
      return nil
    end

    p.code
  end
end
