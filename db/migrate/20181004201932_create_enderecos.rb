class CreateEnderecos < ActiveRecord::Migration[5.2]
  def change
    create_table :enderecos do |t|
      t.references :usuario,  foreign_key: true, index: true, null: false

      t.string :rua,          null: false,  default: "",  limit: 80
      t.string :numero,       null: false,  default: "",  limit: 20
      t.string :complemento,  null: false,  default: "",  limit: 40
      t.string :bairro,       null: false,  default: "",  limit: 60
      t.string :cidade,       null: false,  default: "",  limit: 60
      t.string :estado,       null: false,  default: "",  limit: 2
      t.string :cep,          null: false,  default: "",  limit: 8

      t.timestamps
    end
  end
end
