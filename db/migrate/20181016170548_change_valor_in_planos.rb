class ChangeValorInPlanos < ActiveRecord::Migration[5.2]
  def change
    change_column :planos, :valor, :decimal, null: false, precision: 6, scale: 2
  end
end
