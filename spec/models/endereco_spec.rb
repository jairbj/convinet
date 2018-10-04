require 'rails_helper'

RSpec.describe Endereco, type: :model do
  context 'tem que pertencer' do
    it 'a um usuário' do
        should belong_to(:usuario)
    end
  end

  context 'validacoes' do        
    context 'é obrigatório' do
      it 'rua' do
        should validate_presence_of(:rua)
      end
      it 'numero' do
        should validate_presence_of(:numero)
      end
      it 'complemento' do
        should validate_presence_of(:complemento)
      end
      it 'bairro' do
        should validate_presence_of(:bairro)
      end
      it 'cidade' do
        should validate_presence_of(:cidade)
      end
      it 'estado' do
        should validate_presence_of(:estado)
      end
      it 'cep' do
        should validate_presence_of(:cep)
      end
    end

    context 'rua' do
      it 'tem que ter no máximo 80 caracteres' do
        should validate_length_of(:rua).is_at_most(80)
      end
    end

    context 'numero' do
      it 'tem que ter no máximo 20 caracteres' do
        should validate_length_of(:numero).is_at_most(20)
      end
    end

    context 'complemento' do
      it 'tem que ter no máximo 40 caracteres' do
        should validate_length_of(:complemento).is_at_most(40)
      end
    end

    context 'bairro' do
      it 'tem que ter no máximo 60 caracteres' do
        should validate_length_of(:bairro).is_at_most(60)
      end
    end

    context 'cidade' do
      it 'tem que ter entre 2 e 60 caracteres' do
        should validate_length_of(:cidade).
        is_at_least(2).is_at_most(80)
      end
    end

    context 'estado' do
      it 'tem que ter 2 caracteres correspondente a sigla do estado' do
        should validate_length_of(:estado).is_at_most(2)
      end
    end

    context 'cep' do
      it 'tem que ter 8 dígitos' do
        should validate_length_of(:cep).is_equal_to(8)
      end

      it 'tem que ser numérico' do
        should validate_numericality_of(:cep)
      end
    end
  end
end
