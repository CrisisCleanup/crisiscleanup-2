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

ActiveRecord::Schema.define(version: 20150717174113) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "invitations", force: :cascade do |t|
    t.integer "user_id"
    t.string  "invitee_email"
    t.string  "token",           null: false
    t.integer "organization_id", null: false
  end

  create_table "legacy_contacts", force: :cascade do |t|
    t.string   "email",                                  null: false
    t.string   "first_name",                             null: false
    t.string   "last_name",                              null: false
    t.integer  "legacy_organization_id"
    t.boolean  "is_primary",             default: false
    t.string   "phone",                                  null: false
    t.string   "appengine_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "legacy_events", force: :cascade do |t|
    t.string   "case_label",                        null: false
    t.string   "counties",             default: [],              array: true
    t.string   "name",                              null: false
    t.string   "short_name",                        null: false
    t.date     "created_date",                      null: false
    t.date     "start_date",                        null: false
    t.date     "end_date"
    t.integer  "num_sites"
    t.string   "reminder_contents"
    t.integer  "reminder_days"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.datetime "timestamp_last_login"
    t.string   "appengine_key"
  end

  create_table "legacy_organization_events", force: :cascade do |t|
    t.integer "legacy_organization_id", null: false
    t.integer "legacy_event_id",        null: false
  end

  create_table "legacy_organizations", force: :cascade do |t|
    t.date     "activate_by"
    t.date     "activated_at"
    t.string   "activation_code"
    t.string   "address"
    t.string   "admin_notes"
    t.string   "city"
    t.boolean  "deprecated",                  default: false
    t.boolean  "does_only_coordination",      default: false
    t.boolean  "does_only_sit_aware",         default: false
    t.boolean  "does_recovery",               default: false
    t.boolean  "does_something_else",         default: false
    t.string   "email"
    t.string   "facebook"
    t.boolean  "is_active",                   default: false
    t.boolean  "is_admin",                    default: false
    t.float    "latitude",                                    null: false
    t.float    "longitude",                                   null: false
    t.string   "name",                                        null: false
    t.boolean  "not_an_org",                  default: false
    t.boolean  "only_session_authentication", default: false
    t.boolean  "org_verified",                default: false
    t.string   "password",                                    null: false
    t.string   "permissions",                                 null: false
    t.string   "phone"
    t.boolean  "physical_presence"
    t.boolean  "publish"
    t.boolean  "reputable"
    t.string   "state"
    t.string   "terms_privacy"
    t.datetime "timestamp_login"
    t.datetime "timestamp_signup",                            null: false
    t.string   "twitter"
    t.string   "url"
    t.text     "voad_referral"
    t.string   "work_area"
    t.string   "zip_code"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "voad_member"
    t.boolean  "mold_treatment"
    t.boolean  "tree_removal"
    t.boolean  "design"
    t.boolean  "replace_appliances"
    t.boolean  "canvass"
    t.boolean  "sanitizing"
    t.boolean  "exterior_debris"
    t.boolean  "water_pumping"
    t.boolean  "appropriate_work"
    t.boolean  "reconstruction"
    t.boolean  "interior_debris"
    t.boolean  "assessment"
    t.boolean  "muck_out"
    t.string   "permission"
    t.boolean  "refurbishing"
    t.boolean  "clean_up"
    t.boolean  "mold_abatement"
    t.boolean  "permits"
    t.boolean  "replace_furniture"
    t.boolean  "gutting"
    t.string   "number_volunteers"
    t.string   "primary_contact_email"
    t.string   "voad_member_url"
    t.string   "appengine_key"
  end

  create_table "legacy_sites", force: :cascade do |t|
    t.string   "address",                             null: false
    t.float    "blurred_latitude",                    null: false
    t.float    "blurred_longitude",                   null: false
    t.string   "case_number",                         null: false
    t.string   "city",                                null: false
    t.integer  "claimed_by"
    t.integer  "legacy_event_id",                     null: false
    t.float    "latitude",                            null: false
    t.float    "longitude",                           null: false
    t.string   "name",                                null: false
    t.string   "phone"
    t.integer  "reported_by"
    t.date     "requested_at"
    t.string   "state",                               null: false
    t.string   "status",                              null: false
    t.string   "work_type",         default: "Other", null: false
    t.hstore   "data"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.date     "request_date"
    t.string   "appengine_key"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "name",                   default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.integer  "legacy_organization_id",                 null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "referring_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "verified",               default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
