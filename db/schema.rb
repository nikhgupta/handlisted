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

ActiveRecord::Schema.define(version: 20150901025227) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "badge_awards", force: :cascade do |t|
    t.integer  "badge_id"
    t.integer  "badgeable_id"
    t.string   "badgeable_type"
    t.text     "reason"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "badges", force: :cascade do |t|
    t.string   "name"
    t.integer  "level"
    t.string   "category"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "badges_sashes", force: :cascade do |t|
    t.integer  "badge_id"
    t.integer  "sash_id"
    t.boolean  "notified_user", default: false
    t.datetime "created_at"
  end

  add_index "badges_sashes", ["badge_id", "sash_id"], name: "index_badges_sashes_on_badge_id_and_sash_id", using: :btree
  add_index "badges_sashes", ["badge_id"], name: "index_badges_sashes_on_badge_id", using: :btree
  add_index "badges_sashes", ["sash_id"], name: "index_badges_sashes_on_sash_id", using: :btree

  create_table "brands", force: :cascade do |t|
    t.integer  "merchant_id",                null: false
    t.string   "name",                       null: false
    t.string   "slug",                       null: false
    t.integer  "average_rating", default: 0, null: false
    t.integer  "ratings_count",  default: 0, null: false
    t.integer  "products_count", default: 0, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "brands", ["merchant_id"], name: "index_brands_on_merchant_id", using: :btree
  add_index "brands", ["name"], name: "index_brands_on_name", using: :btree
  add_index "brands", ["slug"], name: "index_brands_on_slug", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.string   "slug",                       null: false
    t.integer  "parent_id"
    t.integer  "lft",                        null: false
    t.integer  "rgt",                        null: false
    t.integer  "depth",          default: 0, null: false
    t.integer  "children_count", default: 0, null: false
    t.integer  "products_count", default: 0, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "categories", ["lft"], name: "index_categories_on_lft", using: :btree
  add_index "categories", ["name"], name: "index_categories_on_name", using: :btree
  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree
  add_index "categories", ["rgt"], name: "index_categories_on_rgt", using: :btree
  add_index "categories", ["slug"], name: "index_categories_on_slug", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id",                               null: false
    t.text     "comment",                               null: false
    t.string   "role",             default: "comments"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "follows", force: :cascade do |t|
    t.integer  "user_id",        null: false
    t.integer  "target_user_id", null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "follows", ["target_user_id"], name: "index_follows_on_target_user_id", using: :btree
  add_index "follows", ["user_id"], name: "index_follows_on_user_id", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider",        limit: 16,                 null: false
    t.string   "uid",             limit: 55,                 null: false
    t.string   "name"
    t.string   "username"
    t.string   "email"
    t.string   "image"
    t.string   "gender",          limit: 8
    t.integer  "timezone_offset"
    t.string   "language",        limit: 4,  default: "en"
    t.string   "url"
    t.boolean  "verified",                   default: false
    t.text     "token",                                      null: false
    t.string   "secret"
    t.string   "refresh_token"
    t.datetime "expires_at"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "identities", ["provider", "uid"], name: "index_identities_on_provider_and_uid", using: :btree
  add_index "identities", ["token"], name: "index_identities_on_token", using: :btree
  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "likes", force: :cascade do |t|
    t.integer  "user_id",           null: false
    t.integer  "target_product_id", null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "likes", ["target_product_id"], name: "index_likes_on_target_product_id", using: :btree
  add_index "likes", ["user_id"], name: "index_likes_on_user_id", using: :btree

  create_table "merchants", force: :cascade do |t|
    t.string   "name",         limit: 20,             null: false
    t.string   "service"
    t.string   "slug",                                null: false
    t.integer  "brands_count",            default: 0, null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "merchants", ["name"], name: "index_merchants_on_name", using: :btree

  create_table "merit_actions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "action_method"
    t.integer  "action_value"
    t.boolean  "had_errors",    default: false
    t.string   "target_model"
    t.integer  "target_id"
    t.text     "target_data"
    t.boolean  "processed",     default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "merit_activity_logs", force: :cascade do |t|
    t.integer  "action_id"
    t.string   "related_change_type"
    t.integer  "related_change_id"
    t.string   "description"
    t.datetime "created_at"
  end

  create_table "merit_score_points", force: :cascade do |t|
    t.integer  "score_id"
    t.integer  "num_points", default: 0
    t.string   "log"
    t.datetime "created_at"
  end

  create_table "merit_scores", force: :cascade do |t|
    t.integer "sash_id"
    t.string  "category", default: "default"
  end

  create_table "products", force: :cascade do |t|
    t.integer  "founder_id",                                       null: false
    t.integer  "merchant_id",                                      null: false
    t.integer  "brand_id"
    t.integer  "category_id"
    t.text     "images",                                                        array: true
    t.string   "pid",                                              null: false
    t.string   "slug",                                             null: false
    t.string   "original_name",                                    null: false
    t.string   "url",                                              null: false
    t.string   "name"
    t.text     "note"
    t.text     "features",                                                      array: true
    t.text     "description"
    t.integer  "price_cents",                      default: 0,     null: false
    t.string   "price_currency",                   default: "USD", null: false
    t.integer  "marked_price_cents",               default: 0,     null: false
    t.string   "marked_price_currency",            default: "USD", null: false
    t.boolean  "available",                        default: false, null: false
    t.boolean  "prioritized",                      default: false, null: false
    t.integer  "average_rating",                   default: 0,     null: false
    t.integer  "ratings_count",                    default: 0,     null: false
    t.string   "lock_version",                     default: "0",   null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "url_hash",              limit: 32,                 null: false
  end

  add_index "products", ["brand_id"], name: "index_products_on_brand_id", using: :btree
  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree
  add_index "products", ["founder_id"], name: "index_products_on_founder_id", using: :btree
  add_index "products", ["merchant_id", "pid"], name: "index_products_on_merchant_id_and_pid", using: :btree
  add_index "products", ["merchant_id"], name: "index_products_on_merchant_id", using: :btree
  add_index "products", ["pid"], name: "index_products_on_pid", using: :btree

  create_table "sashes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                                   null: false
    t.string   "gender"
    t.string   "image"
    t.string   "language"
    t.integer  "timezone_offset"
    t.string   "slug"
    t.boolean  "admin",                  default: false
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "found_products_count",   default: 0,     null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "fake_personna",          default: false
    t.string   "username",                               null: false
    t.integer  "sash_id"
    t.integer  "level",                  default: 0
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "brands", "merchants"
  add_foreign_key "identities", "users"
  add_foreign_key "products", "brands"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "merchants"
  add_foreign_key "products", "users", column: "founder_id"
end
