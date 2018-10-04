require 'rails_helper'

RSpec.describe Telefone, type: :model do
  context 'tem que pertencer' do
    it 'a um usuário' do
        should belong_to(:usuario)
    end
  end

  context 'validacoes' do        
    context 'é obrigatório' do
      it 'ddd' do
        should validate_presence_of(:ddd)
      end
      it 'numero' do
        should validate_presence_of(:numero)
      end      
    end

    context 'ddd' do
      it 'tem que ter 2 digitos' do
        should validate_length_of(:ddd).is_equal_to(2)
      end

      it 'tem que ser numerico' do
        should validate_numericalitt_of(:ddd)
      end
    end

    context 'numero' do
      it 'tem que ter 8 ou 9 digitos' do
        should validate_length_of(:numero).
        is_at_least(8).is_at_most(9)
      end

      it 'tem que ser numerico' do
        should validate_numericalitt_of(:numero)
      end
    end    
  end
end
