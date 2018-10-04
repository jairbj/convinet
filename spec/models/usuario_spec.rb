require 'rails_helper'

RSpec.describe Usuario, type: :model do
  context 'relacionamentos' do
    context 'pode_ter' do
      it 'um endereco' do
        should have_one(:endereco)
      end

      it 'um telefone' do
        should have_one(:telefone)
      end
    end
  end

  context 'validacoes' do    
    let(:usuario) { build(:usuario) }
    it 'o FACTORIE é válido' do
      expect(usuario).to be_valid
    end

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

    context 'cpf' do
      it 'tem que ser valido' do
        usuario.cpf = '99999999900'
        expect(usuario).to_not be_valid
      end

      it 'tem que ter 12 digitos' do
        should validate_length_of(:cpf).is_equal_to(12)
      end

      it 'tem que ser numérico' do
        should validate_numericalitt_of(:cpf)
      end
    end

    context 'email' do
      it 'tem que ser transformado em minusculo' do
        usuario.email = 'FULANO@PROVEDOR.COM.BR'
        expect(usuario.save).to be_truthy
        expect(usuario.email).to eq('fulano@provedor.com.br')
      end

      it 'nao pode ser invalido' do
        usuario.email = 'emailinvalido'
        expect(usuario).to_not be_valid
        usuario.email = 'email@invalido'
        expect(usuario).to_not be_valid
      end

      it 'tem que aceitar 1 tld' do
        usuario.email = 'usuario@provedor.com'
        expect(usuario).to be_valid
      end

      it 'tem que aceitar 2 tld' do
        usuario.email = 'usuario@provedor.com.br'
        expect(usuario).to be_valid
      end
    end
  end
end
