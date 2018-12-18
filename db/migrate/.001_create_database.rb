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
class CreateDatabase < ActiveRecord::Migration

  def self.up
    ActiveRecord::Schema.define(version: 0) do

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

      add_foreign_key "documents", "professors", column: "numeroPersonal", primary_key: "numeroPersonal", name: "fk_Documento_Academico"
      add_foreign_key "partners", "documents", column: "idDocumento", primary_key: "idDocumento", name: "fk_Academico_has_Documento_Documento1"
      add_foreign_key "partners", "professors", column: "numeroPersonal", primary_key: "numeroPersonal", name: "fk_Academico_has_Documento_Academico1"
    end
  end

  def self.down

  end
end
