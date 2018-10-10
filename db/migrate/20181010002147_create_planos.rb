class CreatePlanos < ActiveRecord::Migration[5.2]
  def change
    create_table :planos do |t|
      t.string :nome,          null: false,   default: ""
      t.string :identificador, null: false,   default: ""
      t.decimal :valor,        null: false,   precision: 4, scale: 2      
      t.string :codigo,        null: false,   default: ""

      t.timestamps
    end
  end
end
