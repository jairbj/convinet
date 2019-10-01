class CreatePreCadastros < ActiveRecord::Migration[5.2]
  def change
    create_table :pre_cadastros do |t|
      t.string      :codigo,  null: false,  limit: 6
      t.integer     :status,  null: false,  default: 0
      t.references  :usuario, null: false,                foreign_key: true
      t.references  :plano,   null: true,   default: '',  foreign_key: true
      t.integer     :tipo,    null: false,  default: 0
      # O valor só será usado para contribuições avulsas
      t.decimal     :valor,   null: true,  default: '0.00', precision: 6, scale: 2

      t.timestamps
    end

    # Índice para o código do pré-cadastro
    add_index :pre_cadastros, :codigo, unique: true
  end
end
