# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_10_10_002516) do

  create_table "contribuicoes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "usuario_id", null: false
    t.bigint "plano_id", null: false
    t.string "codigo", default: "", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plano_id"], name: "index_contribuicoes_on_plano_id"
    t.index ["usuario_id"], name: "index_contribuicoes_on_usuario_id"
  end

  create_table "enderecos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "usuario_id", null: false
    t.string "rua", limit: 80, default: "", null: false
    t.string "numero", limit: 20, default: "", null: false
    t.string "complemento", limit: 40, default: "", null: false
    t.string "bairro", limit: 60, default: "", null: false
    t.string "cidade", limit: 60, default: "", null: false
    t.string "estado", limit: 2, default: "", null: false
    t.string "cep", limit: 8, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["usuario_id"], name: "index_enderecos_on_usuario_id"
  end

  create_table "planos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "nome", default: "", null: false
    t.string "identificador", default: "", null: false
    t.decimal "valor", precision: 4, scale: 2, null: false
    t.string "codigo", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "telefones", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "usuario_id", null: false
    t.string "ddd", limit: 2, default: "", null: false
    t.string "numero", limit: 9, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["usuario_id"], name: "index_telefones_on_usuario_id"
  end

  create_table "usuarios", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "nome", default: "", null: false
    t.string "cpf", limit: 11, default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cpf"], name: "index_usuarios_on_cpf", unique: true
    t.index ["email"], name: "index_usuarios_on_email", unique: true
    t.index ["reset_password_token"], name: "index_usuarios_on_reset_password_token", unique: true
  end

  add_foreign_key "contribuicoes", "planos"
  add_foreign_key "contribuicoes", "usuarios"
  add_foreign_key "enderecos", "usuarios"
  add_foreign_key "telefones", "usuarios"
end
