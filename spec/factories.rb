FactoryBot.define do
  factory :usuario do
    nome  { 'Fulano de Tal' }
    email { 'fulano@provedor.com.br' }
    cpf   { '00000000191' }
    
    password              { '12345678' }
    password_confirmation { '12345678' }
  end
end