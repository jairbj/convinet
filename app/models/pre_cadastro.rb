class PreCadastro < ApplicationRecord
  belongs_to :usuario
  belongs_to :plano, optional: true

  enum status: {ativo: 0, efetuado: 1, cancelado: 2}
  enum tipo: Contribuicao.tipos

  # Validações
  # Valor
  validates :valor, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1
  }
  # Plano
  validate :plano_valido, if: :mensal?

  before_validation :gera_codigo

  private

  def plano_valido
    return if self.plano

    self.plano = Plano.find_by(valor: self.valor)
    return if self.plano

    cria_plano
  end

  def cria_plano
    plano = Plano.new
    plano.valor = self.valor
    plano.identificador = Rails.configuration.convinet['prefixo_plano_pagseguro'] + plano.valor.to_i.to_s
    plano.nome = plano.identificador

    plano.codigo = plano.criaPagSeguro

    if plano.codigo
      plano.save
      self.plano = plano
      return
    end

    errors.add(:plano, 'Erro ao registrar plano no PagSeguro. Tente novamente.')
  end

  def gera_codigo
    return if self.codigo

    loop do
      # Gera um código aleatório
      self.codigo = generate_alfa_code(6)
      # Se não existir um código igual, sai do loop
      break unless PreCadastro.exists? codigo: self.codigo
    end
  end

  def generate_alfa_code(size)
    # Generates a random string from a set of easily readable characters
    charset = %w[2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z]
    (0...size).map{ charset.to_a[rand(charset.size)] }.join
  end
end
