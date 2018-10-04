class CreateTelefones < ActiveRecord::Migration[5.2]
  def change
    create_table :telefones do |t|
      t.references :usuario,  foreign_key: true, index: true, null: false

      t.string :ddd,          null: false,  default: "",  limit: 2
      t.string :numero,       null: false,  default: "",  limit: 9

      t.timestamps
    end
  end
end
