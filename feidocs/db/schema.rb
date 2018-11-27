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

ActiveRecord::Schema.define(version: 2018_11_27_020814) do

  create_table "documents", primary_key: "idDocumento", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "nombre", limit: 45, null: false
    t.text "path", limit: 255, null: false
    t.integer "numeroPersonal", null: false
    t.index ["numeroPersonal"], name: "fk_Documento_Academico_idx"
  end

  create_table "partners", primary_key: ["numeroPersonal", "idDocumento"], options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "numeroPersonal", null: false
    t.integer "idDocumento", null: false
    t.index ["idDocumento"], name: "fk_Academico_has_Documento_Documento1_idx"
    t.index ["numeroPersonal"], name: "fk_Academico_has_Documento_Academico1_idx"
  end

  create_table "professors", primary_key: "numeroPersonal", id: :integer, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "nombres", limit: 45, null: false
    t.string "apellidos", limit: 45, null: false
    t.string "correo", limit: 45, null: false
    t.string "contraseña", limit: 64, null: false
    t.binary "foto", limit: 4294967295, null: false
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "documents", "professors", column: "numeroPersonal", primary_key: "numeropersonal", name: "fk_Documento_Academico"
  add_foreign_key "partners", "documents", column: "idDocumento", primary_key: "iddocumento", name: "fk_Academico_has_Documento_Documento1"
  add_foreign_key "partners", "professors", column: "numeroPersonal", primary_key: "numeropersonal", name: "fk_Academico_has_Documento_Academico1"
end
