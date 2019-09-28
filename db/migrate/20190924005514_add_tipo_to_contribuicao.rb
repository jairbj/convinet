class AddTipoToContribuicao < ActiveRecord::Migration[5.2]
  def change
    add_column :contribuicoes, :tipo, :integer,
                               null: false,
                               default: 0,
                               after: :status
  end
end
