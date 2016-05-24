# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160523183927) do

  create_table "sources", force: :cascade do |t|
    t.string   "filename"
    t.integer  "year"
    t.integer  "month"
    t.integer  "generation"
    t.string   "tier"
    t.integer  "min_rank"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "usages", force: :cascade do |t|
    t.integer  "source_id"
    t.string   "pokemon"
    t.float    "usage_pct"
    t.integer  "raw"
    t.float    "raw_pct"
    t.integer  "real"
    t.float    "real_pct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
