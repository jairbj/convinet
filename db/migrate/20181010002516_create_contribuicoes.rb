class CreateContribuicoes < ActiveRecord::Migration[5.2]
  def change
    create_table :contribuicoes do |t|
      t.references :usuario,  foreign_key: true, null: false
      t.references :plano,    foreign_key: true, null: false
      t.string :codigo,       null: false,  default: ""
      t.integer :status,      null: false,  default: 0

      t.timestamps
    end
  end
end
