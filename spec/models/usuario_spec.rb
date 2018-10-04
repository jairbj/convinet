require 'rails_helper'

RSpec.describe Usuario, type: :model do
  context 'validacoes' do    
    context 'é obrigatório' do
      it 'nome' do
        should validate_presence_of(:nome)
      end
      it 'cpf' do
        should validate_presence_of(:cpf)
      end
      it 'email' do
        should validate_presence_of(:email)
      end
    end
    context 'tem que ser único' do
      it 'email' do
        should validate_uniqueness_of(:email)
      end
      it 'cpf' do
        should validate_uniqueness_of(:cpf)
      end
    end
  end
end
